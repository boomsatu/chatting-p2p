use crate::p2p::node;
use crate::frb_generated::StreamSink;
use once_cell::sync::Lazy;
use std::sync::RwLock;

static PEER_EVENT_SINK: Lazy<RwLock<Option<StreamSink<String>>>> = Lazy::new(|| RwLock::new(None));

pub fn register_peer_event_stream(sink: StreamSink<String>) -> Result<(), String> {
    let mut write_lock = PEER_EVENT_SINK.write().unwrap();
    *write_lock = Some(sink);
    Ok(())
}

pub fn get_peer_event_sink() -> Option<StreamSink<String>> {
    let read_lock = PEER_EVENT_SINK.read().unwrap();
    read_lock.clone()
}

pub fn start_node() -> Result<String, String> {
    node::start_node().map_err(|e| e.to_string())
}

pub fn stop_node() -> Result<(), String> {
    node::stop_node().map_err(|e| e.to_string())
}

pub fn is_node_running() -> bool {
    node::is_node_running()
}

pub fn get_peer_id() -> Option<String> {
    node::get_peer_id()
}

pub async fn dial_peer(multiaddr: String) -> Result<(), String> {
    node::dial(multiaddr).await
}

pub async fn get_peer_count() -> Result<usize, String> {
    node::get_peer_count().await
}

pub async fn subscribe_to_topic(topic: String) -> Result<bool, String> {
    node::subscribe(topic).await
}

pub async fn unsubscribe_from_topic(topic: String) -> Result<bool, String> {
    node::unsubscribe(topic).await
}

pub async fn publish_message(topic: String, data: Vec<u8>) -> Result<(), String> {
    node::publish(topic, data).await
}

pub async fn publish_presence() -> Result<(), String> {
    let my_keys = crate::crypto::keystore::get_identity_keys()
        .ok_or_else(|| "Identity not set".to_string())?;

    let timestamp = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_millis() as u64;

    let mut envelope = crate::models::message::MessageEnvelope {
        v: 1,
        id: uuid::Uuid::new_v4().to_string(),
        msg_type: crate::models::message::MessageType::Presence,
        sender: my_keys.peer_id.clone(),
        timestamp,
        payload: crate::models::message::EncryptedPayload::None,
        sig: "".to_string(),
    };

    let signing_key = crate::crypto::keystore::get_signing_key()
        .map_err(|e| e.to_string())?;
    envelope.sign(&signing_key).map_err(|e| e.to_string())?;

    let topic = crate::p2p::topics::presence_topic(&my_keys.peer_id);
    let envelope_bytes = serde_json::to_vec(&envelope)
        .map_err(|e| e.to_string())?;

    node::publish(topic, envelope_bytes).await?;
    Ok(())
}
