use std::sync::RwLock;
use std::time::Duration;
use once_cell::sync::Lazy;
use tokio::sync::oneshot;
use libp2p::{swarm::NetworkBehaviour, swarm::SwarmEvent, PeerId, futures::StreamExt};
use crate::crypto::keystore;

#[derive(NetworkBehaviour)]
pub(crate) struct P2PChatBehaviour {
    pub(crate) identify: libp2p::identify::Behaviour,
    pub(crate) mdns: libp2p::mdns::tokio::Behaviour,
    pub(crate) gossipsub: libp2p::gossipsub::Behaviour,
    pub(crate) relay_client: libp2p::relay::client::Behaviour,
    pub(crate) dcutr: libp2p::dcutr::Behaviour,
}

pub enum Command {
    Publish {
        topic: String,
        data: Vec<u8>,
        response: tokio::sync::oneshot::Sender<Result<(), String>>,
    },
    Subscribe {
        topic: String,
        response: tokio::sync::oneshot::Sender<Result<bool, String>>,
    },
    Unsubscribe {
        topic: String,
        response: tokio::sync::oneshot::Sender<Result<bool, String>>,
    },
    Dial {
        multiaddr: String,
        response: tokio::sync::oneshot::Sender<Result<(), String>>,
    },
    GetPeerCount {
        response: tokio::sync::oneshot::Sender<usize>,
    },
}

pub struct NodeController {
    shutdown_tx: oneshot::Sender<()>,
    command_tx: tokio::sync::mpsc::Sender<Command>,
    pub peer_id: String,
}

static NODE_CONTROLLER: Lazy<RwLock<Option<NodeController>>> = Lazy::new(|| RwLock::new(None));

pub fn start_node() -> anyhow::Result<String> {
    // 1. Check if node is already running
    {
        let read_lock = NODE_CONTROLLER.read().unwrap();
        if let Some(ref controller) = *read_lock {
            return Ok(controller.peer_id.clone());
        }
    }

    // 2. Get keys from keystore (or generate if not set for PoC convenience)
    let keypair = match keystore::get_libp2p_keypair() {
        Ok(kp) => kp,
        Err(_) => {
            log::warn!("Identity keys not set. Generating temporary identity.");
            let random_identity = crate::crypto::identity::generate_random_identity()?;
            keystore::set_identity_keys(random_identity);
            keystore::get_libp2p_keypair()?
        }
    };

    let peer_id = PeerId::from(keypair.public());
    let peer_id_str = peer_id.to_string();

    let (relay_transport, relay_client) = libp2p::relay::client::new(peer_id);
    let dcutr = libp2p::dcutr::Behaviour::new(peer_id);
    let identify = libp2p::identify::Behaviour::new(
        libp2p::identify::Config::new("/p2pchat/1.0.0".to_string(), keypair.public())
    );
    let mdns = libp2p::mdns::tokio::Behaviour::new(
        libp2p::mdns::Config::default(),
        peer_id,
    )?;
    let gossipsub_config = crate::p2p::gossipsub::build_gossipsub_config();
    let gossipsub = libp2p::gossipsub::Behaviour::new(
        libp2p::gossipsub::MessageAuthenticity::Signed(keypair.clone()),
        gossipsub_config,
    ).map_err(|e| anyhow::anyhow!("Gossipsub init failed: {:?}", e))?;

    let behaviour = P2PChatBehaviour { identify, mdns, gossipsub, relay_client, dcutr };

    // 3. Build the swarm
    let mut swarm = libp2p::SwarmBuilder::with_existing_identity(keypair.clone())
        .with_tokio()
        .with_tcp(
            libp2p::tcp::Config::default(),
            libp2p::noise::Config::new,
            libp2p::yamux::Config::default,
        )?
        .with_quic()
        .with_behaviour(|_| Ok(behaviour))?
        .with_swarm_config(|c| c.with_idle_connection_timeout(Duration::from_secs(60)))
        .build();

    // 4. Bind listeners
    swarm.listen_on("/ip4/0.0.0.0/tcp/0".parse()?)?;
    swarm.listen_on("/ip4/0.0.0.0/udp/0/quic-v1".parse()?)?;

    // 5. Create channels
    let (shutdown_tx, mut shutdown_rx) = oneshot::channel::<()>();
    let (command_tx, mut command_rx) = tokio::sync::mpsc::channel::<Command>(100);

    // 6. Spawn Swarm Event Loop in Tokio background task
    tokio::spawn(async move {
        let _keep_alive = relay_transport;
        log::info!("Swarm event loop started for PeerID: {}", peer_id);
        loop {
            tokio::select! {
                _ = &mut shutdown_rx => {
                    log::info!("Shutting down swarm event loop");
                    break;
                }
                cmd_opt = command_rx.recv() => {
                    if let Some(cmd) = cmd_opt {
                        match cmd {
                            Command::Publish { topic, data, response } => {
                                let gossipsub_topic = libp2p::gossipsub::IdentTopic::new(topic);
                                let res = swarm.behaviour_mut().gossipsub.publish(gossipsub_topic, data)
                                    .map(|_| ())
                                    .map_err(|e| e.to_string());
                                let _ = response.send(res);
                            }
                            Command::Subscribe { topic, response } => {
                                let gossipsub_topic = libp2p::gossipsub::IdentTopic::new(topic);
                                let res = swarm.behaviour_mut().gossipsub.subscribe(&gossipsub_topic)
                                    .map_err(|e| e.to_string());
                                let _ = response.send(res);
                            }
                            Command::Unsubscribe { topic, response } => {
                                let gossipsub_topic = libp2p::gossipsub::IdentTopic::new(topic);
                                let res = Ok(swarm.behaviour_mut().gossipsub.unsubscribe(&gossipsub_topic));
                                let _ = response.send(res);
                            }
                            Command::Dial { multiaddr, response } => {
                                let res = match multiaddr.parse::<libp2p::Multiaddr>() {
                                    Ok(addr) => {
                                        swarm.dial(addr).map(|_| ()).map_err(|e| e.to_string())
                                    }
                                    Err(e) => Err(e.to_string()),
                                };
                                let _ = response.send(res);
                            }
                            Command::GetPeerCount { response } => {
                                let count = swarm.connected_peers().count();
                                let _ = response.send(count);
                            }
                        }
                    }
                }
                event = swarm.select_next_some() => {
                    match event {
                        SwarmEvent::NewListenAddr { address, .. } => {
                            log::info!("Listening on {:?}", address);
                        }
                        SwarmEvent::ConnectionEstablished { peer_id, .. } => {
                            let peer_id_str = peer_id.to_string();
                            log::info!("Connection established with {}", peer_id_str);
                            if let Some(sink) = crate::api::node_api::get_peer_event_sink() {
                                let _ = sink.add(format!("{{\"event\": \"connected\", \"peer_id\": \"{}\"}}", peer_id_str));
                            }
                        }
                        SwarmEvent::ConnectionClosed { peer_id, .. } => {
                            let peer_id_str = peer_id.to_string();
                            log::info!("Connection closed with {}", peer_id_str);
                            if let Some(sink) = crate::api::node_api::get_peer_event_sink() {
                                let _ = sink.add(format!("{{\"event\": \"disconnected\", \"peer_id\": \"{}\"}}", peer_id_str));
                            }
                        }
                        SwarmEvent::Behaviour(P2PChatBehaviourEvent::Mdns(event)) => {
                            match event {
                                libp2p::mdns::Event::Discovered(list) => {
                                    for (peer, addr) in list {
                                        log::info!("mDNS discovered peer {} at {:?}", peer, addr);
                                        let _ = swarm.dial(addr);
                                    }
                                }
                                libp2p::mdns::Event::Expired(list) => {
                                    for (peer, addr) in list {
                                        log::info!("mDNS expired peer {} at {:?}", peer, addr);
                                    }
                                }
                            }
                        }
                        SwarmEvent::Behaviour(P2PChatBehaviourEvent::Gossipsub(event)) => {
                            log::info!("Gossipsub event: {:?}", event);
                            if let libp2p::gossipsub::Event::Message { message, .. } = event {
                                if let Ok(json_str) = String::from_utf8(message.data) {
                                    if let Some(sink) = crate::api::chat_api::get_message_sink() {
                                        let _ = sink.add(json_str);
                                    }
                                }
                            }
                        }
                        SwarmEvent::Behaviour(P2PChatBehaviourEvent::RelayClient(event)) => {
                            log::info!("Relay client event: {:?}", event);
                        }
                        SwarmEvent::Behaviour(P2PChatBehaviourEvent::Dcutr(event)) => {
                            log::info!("DCUtR event: {:?}", event);
                        }
                        _ => {}
                    }
                }
            }
        }
    });

    // 7. Store the controller
    let mut write_lock = NODE_CONTROLLER.write().unwrap();
    *write_lock = Some(NodeController {
        shutdown_tx,
        command_tx,
        peer_id: peer_id_str.clone(),
    });

    Ok(peer_id_str)
}

pub fn stop_node() -> anyhow::Result<()> {
    let mut write_lock = NODE_CONTROLLER.write().unwrap();
    if let Some(controller) = write_lock.take() {
        let _ = controller.shutdown_tx.send(());
        log::info!("Node stopped successfully");
    }
    Ok(())
}

pub fn is_node_running() -> bool {
    let read_lock = NODE_CONTROLLER.read().unwrap();
    read_lock.is_some()
}

pub fn get_peer_id() -> Option<String> {
    let read_lock = NODE_CONTROLLER.read().unwrap();
    read_lock.as_ref().map(|c| c.peer_id.clone())
}

// Command execution wrappers for FFI

pub async fn publish(topic: String, data: Vec<u8>) -> Result<(), String> {
    let tx = {
        let read_lock = NODE_CONTROLLER.read().unwrap();
        if let Some(ref controller) = *read_lock {
            controller.command_tx.clone()
        } else {
            return Err("Node is not running".to_string());
        }
    };
    let (resp_tx, resp_rx) = tokio::sync::oneshot::channel();
    tx.send(Command::Publish { topic, data, response: resp_tx })
        .await
        .map_err(|e| e.to_string())?;
    resp_rx.await.map_err(|e| e.to_string())?
}

pub async fn subscribe(topic: String) -> Result<bool, String> {
    let tx = {
        let read_lock = NODE_CONTROLLER.read().unwrap();
        if let Some(ref controller) = *read_lock {
            controller.command_tx.clone()
        } else {
            return Err("Node is not running".to_string());
        }
    };
    let (resp_tx, resp_rx) = tokio::sync::oneshot::channel();
    tx.send(Command::Subscribe { topic, response: resp_tx })
        .await
        .map_err(|e| e.to_string())?;
    resp_rx.await.map_err(|e| e.to_string())?
}

pub async fn unsubscribe(topic: String) -> Result<bool, String> {
    let tx = {
        let read_lock = NODE_CONTROLLER.read().unwrap();
        if let Some(ref controller) = *read_lock {
            controller.command_tx.clone()
        } else {
            return Err("Node is not running".to_string());
        }
    };
    let (resp_tx, resp_rx) = tokio::sync::oneshot::channel();
    tx.send(Command::Unsubscribe { topic, response: resp_tx })
        .await
        .map_err(|e| e.to_string())?;
    resp_rx.await.map_err(|e| e.to_string())?
}

pub async fn dial(multiaddr: String) -> Result<(), String> {
    let tx = {
        let read_lock = NODE_CONTROLLER.read().unwrap();
        if let Some(ref controller) = *read_lock {
            controller.command_tx.clone()
        } else {
            return Err("Node is not running".to_string());
        }
    };
    let (resp_tx, resp_rx) = tokio::sync::oneshot::channel();
    tx.send(Command::Dial { multiaddr, response: resp_tx })
        .await
        .map_err(|e| e.to_string())?;
    resp_rx.await.map_err(|e| e.to_string())?
}

pub async fn get_peer_count() -> Result<usize, String> {
    let tx = {
        let read_lock = NODE_CONTROLLER.read().unwrap();
        if let Some(ref controller) = *read_lock {
            controller.command_tx.clone()
        } else {
            return Err("Node is not running".to_string());
        }
    };
    let (resp_tx, resp_rx) = tokio::sync::oneshot::channel();
    tx.send(Command::GetPeerCount { response: resp_tx })
        .await
        .map_err(|e| e.to_string())?;
    resp_rx.await.map_err(|e| e.to_string())
}
