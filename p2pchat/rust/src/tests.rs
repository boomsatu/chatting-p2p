#[cfg(test)]
mod tests {
    use crate::crypto::{identity, dm_crypto, group_crypto};
    use crate::p2p::topics;
    use crate::p2p::gossipsub::build_gossipsub_config;

    #[test]
    fn test_topic_naming() {
        // Sorted topic names for peer A and peer B
        let peer_a = "peer_alice";
        let peer_b = "peer_bob";
        assert_eq!(topics::dm_topic(peer_a, peer_b), "dm:peer_alice:peer_bob");
        assert_eq!(topics::dm_topic(peer_b, peer_a), "dm:peer_alice:peer_bob");

        assert_eq!(topics::group_topic("my-group-123"), "group:my-group-123");
        assert_eq!(topics::presence_topic("peer_alice"), "presence:peer_alice");
        assert_eq!(topics::invite_topic("peer_bob"), "invite:peer_bob");
    }

    #[test]
    fn test_identity_determinism() {
        let seed = [7u8; 32];
        let id1 = identity::generate_identity_from_seed(&seed).unwrap();
        let id2 = identity::generate_identity_from_seed(&seed).unwrap();

        assert_eq!(id1.peer_id, id2.peer_id);
        assert_eq!(id1.signing_pubkey, id2.signing_pubkey);
        assert_eq!(id1.box_pubkey, id2.box_pubkey);
    }

    #[test]
    fn test_dm_encryption_roundtrip() {
        let alice_keys = identity::generate_random_identity().unwrap();
        let bob_keys = identity::generate_random_identity().unwrap();

        let plaintext = b"Hello from Alice to Bob!";

        // We use keystore / derived seeds for realism
        use crate::crypto::keystore;
        keystore::set_identity_keys(alice_keys.clone());
        let alice_secret_box = keystore::get_box_secret().unwrap();
        let alice_pub_box = x25519_dalek::PublicKey::from(&alice_secret_box);
        
        keystore::set_identity_keys(bob_keys.clone());
        let bob_secret_box = keystore::get_box_secret().unwrap();
        let bob_pub_box = x25519_dalek::PublicKey::from(&bob_secret_box);

        // Alice encrypts to Bob
        let (ciphertext, nonce) = dm_crypto::encrypt_dm(
            plaintext,
            &bob_pub_box.to_bytes(),
            &alice_secret_box.to_bytes(),
        ).unwrap();

        // Bob decrypts from Alice
        let decrypted = dm_crypto::decrypt_dm(
            &ciphertext,
            &nonce,
            &alice_pub_box.to_bytes(),
            &bob_secret_box.to_bytes(),
        ).unwrap();

        assert_eq!(decrypted, plaintext);
    }

    #[test]
    fn test_group_encryption_roundtrip() {
        let group_key = group_crypto::generate_group_key();
        let plaintext = b"Top secret group message";

        let (ciphertext, nonce) = group_crypto::encrypt_group(plaintext, &group_key).unwrap();
        let decrypted = group_crypto::decrypt_group(&ciphertext, &nonce, &group_key).unwrap();

        assert_eq!(decrypted, plaintext);
    }

    #[test]
    fn test_gossipsub_config_validation() {
        let config = build_gossipsub_config();
        assert_eq!(config.heartbeat_interval(), std::time::Duration::from_secs(1));
        assert_eq!(config.max_transmit_size(), 65536);
    }

    #[test]
    fn test_envelope_signing_and_verification() {
        let alice_identity = identity::generate_random_identity().unwrap();
        let seed_bytes: [u8; 32] = alice_identity.seed.clone().try_into().unwrap();
        let signing_key = ed25519_dalek::SigningKey::from_bytes(&seed_bytes);
        
        let mut envelope = crate::models::message::MessageEnvelope {
            v: 1,
            id: "test-uuid-456".to_string(),
            msg_type: crate::models::message::MessageType::Chat,
            sender: alice_identity.peer_id.clone(),
            timestamp: 123456789,
            payload: crate::models::message::EncryptedPayload::None,
            sig: "".to_string(),
        };

        // Sign
        envelope.sign(&signing_key).unwrap();
        assert!(!envelope.sig.is_empty());

        // Verify
        let pubkey_bytes: [u8; 32] = alice_identity.signing_pubkey.clone().try_into().unwrap();
        let is_valid = envelope.verify(&pubkey_bytes);
        assert!(is_valid);

        // Tamper test
        envelope.id = "tampered-uuid-999".to_string();
        let is_valid_tampered = envelope.verify(&pubkey_bytes);
        assert!(!is_valid_tampered);
    }

    #[test]
    fn test_envelope_serialization_deserialization() {
        let alice_identity = identity::generate_random_identity().unwrap();
        let dm_payload = crate::models::message::DMPayload {
            nonce: "nonce_placeholder".to_string(),
            ciphertext: "ciphertext_placeholder".to_string(),
            sender_pub_key: "sender_pubkey_placeholder".to_string(),
        };

        let envelope = crate::models::message::MessageEnvelope {
            v: 1,
            id: "msg-123".to_string(),
            msg_type: crate::models::message::MessageType::Chat,
            sender: alice_identity.peer_id.clone(),
            timestamp: 9999999,
            payload: crate::models::message::EncryptedPayload::Dm(dm_payload),
            sig: "sig_placeholder".to_string(),
        };

        // Serialize
        let json_str = serde_json::to_string(&envelope).unwrap();
        assert!(json_str.contains("msg-123"));

        // Deserialize
        let deserialized: crate::models::message::MessageEnvelope = serde_json::from_str(&json_str).unwrap();
        assert_eq!(deserialized.id, "msg-123");
        assert_eq!(deserialized.sender, alice_identity.peer_id);
        if let crate::models::message::EncryptedPayload::Dm(ref payload) = deserialized.payload {
            assert_eq!(payload.nonce, "nonce_placeholder");
        } else {
            panic!("Expected EncryptedPayload::Dm");
        }
    }

    #[tokio::test]
    async fn test_gossipsub_publish_subscribe_commands() {
        // Start node (binds to port 0 dynamically, perfectly safe and isolated)
        let peer_id = crate::p2p::node::start_node().unwrap();
        assert!(!peer_id.is_empty());
        assert!(crate::p2p::node::is_node_running());

        // Test subscribe
        let sub_res = crate::p2p::node::subscribe("test-gossipsub-topic".to_string()).await;
        assert!(sub_res.is_ok());

        // Test publish
        let pub_res = crate::p2p::node::publish("test-gossipsub-topic".to_string(), vec![4, 5, 6]).await;
        if let Err(ref err_str) = pub_res {
            assert_eq!(err_str, "NoPeersSubscribedToTopic");
        } else {
            assert!(pub_res.is_ok());
        }

        // Test unsubscribe
        let unsub_res = crate::p2p::node::unsubscribe("test-gossipsub-topic".to_string()).await;
        assert!(unsub_res.is_ok());

        // Stop node
        crate::p2p::node::stop_node().unwrap();
        assert!(!crate::p2p::node::is_node_running());
    }

    #[test]
    fn test_send_dm_flow_integration_mock() {
        let alice_identity = identity::generate_random_identity().unwrap();
        let bob_identity = identity::generate_random_identity().unwrap();

        // 1. Get our own keys and PeerID
        use crate::crypto::keystore;
        keystore::set_identity_keys(alice_identity.clone());
        let alice_signing_key = keystore::get_signing_key().unwrap();
        let alice_secret_box = keystore::get_box_secret().unwrap();

        let bob_pub_box_bytes: [u8; 32] = bob_identity.box_pubkey.clone().try_into().unwrap();

        // 2. Build the ChatMessage
        let chat_msg = crate::models::message::ChatMessage {
            content: "Hello Bob!".to_string(),
            content_type: crate::models::message::ContentType::Text,
            reply_to_id: None,
            metadata: None,
        };
        let chat_msg_bytes = serde_json::to_vec(&chat_msg).unwrap();

        // 3. Encrypt payload
        let (ciphertext, nonce) = crate::crypto::dm_crypto::encrypt_dm(
            &chat_msg_bytes,
            &bob_pub_box_bytes,
            &alice_secret_box.to_bytes(),
        ).unwrap();

        let dm_payload = crate::models::message::DMPayload {
            nonce: base64::Engine::encode(&base64::prelude::BASE64_STANDARD, &nonce),
            ciphertext: base64::Engine::encode(&base64::prelude::BASE64_STANDARD, &ciphertext),
            sender_pub_key: base64::Engine::encode(&base64::prelude::BASE64_STANDARD, &alice_identity.box_pubkey),
        };

        // 4. Create MessageEnvelope
        let mut envelope = crate::models::message::MessageEnvelope {
            v: 1,
            id: "msg-999".to_string(),
            msg_type: crate::models::message::MessageType::Chat,
            sender: alice_identity.peer_id.clone(),
            timestamp: 123456,
            payload: crate::models::message::EncryptedPayload::Dm(dm_payload),
            sig: "".to_string(),
        };

        // 5. Sign the envelope
        envelope.sign(&alice_signing_key).unwrap();
        assert!(!envelope.sig.is_empty());

        // 6. Verify Bob can decrypt and verify Alice's signature
        let alice_signing_pubkey_bytes: [u8; 32] = alice_identity.signing_pubkey.clone().try_into().unwrap();
        let is_sig_valid = envelope.verify(&alice_signing_pubkey_bytes);
        assert!(is_sig_valid);

        // 7. Verify decryption
        if let crate::models::message::EncryptedPayload::Dm(ref payload) = envelope.payload {
            let decoded_ciphertext = base64::Engine::decode(&base64::prelude::BASE64_STANDARD, &payload.ciphertext).unwrap();
            let decoded_nonce = base64::Engine::decode(&base64::prelude::BASE64_STANDARD, &payload.nonce).unwrap();
            let nonce_arr: [u8; 24] = decoded_nonce.try_into().unwrap();

            let bob_seed_bytes: [u8; 32] = bob_identity.seed.clone().try_into().unwrap();
            use sha2::{Sha256, Digest};
            let mut hasher = Sha256::new();
            hasher.update(&bob_seed_bytes);
            hasher.update(b"x25519-derivation");
            let derived_bytes: [u8; 32] = hasher.finalize().into();
            let bob_secret_box = x25519_dalek::StaticSecret::from(derived_bytes);
            let alice_pub_box_bytes: [u8; 32] = alice_identity.box_pubkey.clone().try_into().unwrap();

            let decrypted = crate::crypto::dm_crypto::decrypt_dm(
                &decoded_ciphertext,
                &nonce_arr,
                &alice_pub_box_bytes,
                &bob_secret_box.to_bytes(),
            ).unwrap();

            let chat_msg_decrypted: crate::models::message::ChatMessage = serde_json::from_slice(&decrypted).unwrap();
            assert_eq!(chat_msg_decrypted.content, "Hello Bob!");
        } else {
            panic!("Expected Dm payload");
        }
    }

    #[tokio::test]
    async fn test_two_nodes_mdns_connection() {
        use libp2p::{swarm::SwarmEvent, futures::StreamExt};
        use std::time::Duration;
        use crate::p2p::node::P2PChatBehaviour;

        // 1. Generate identity A
        let alice_identity = identity::generate_random_identity().unwrap();
        let alice_keypair = libp2p::identity::Keypair::ed25519_from_bytes(alice_identity.seed).unwrap();
        let alice_peer_id = alice_keypair.public().to_peer_id();

        let (alice_relay_transport, alice_relay_client) = libp2p::relay::client::new(alice_peer_id);
        let alice_dcutr = libp2p::dcutr::Behaviour::new(alice_peer_id);
        let alice_identify = libp2p::identify::Behaviour::new(
            libp2p::identify::Config::new("/p2pchat/1.0.0".to_string(), alice_keypair.public())
        );
        let alice_mdns = libp2p::mdns::tokio::Behaviour::new(
            libp2p::mdns::Config::default(),
            alice_peer_id,
        ).unwrap();
        let alice_gossipsub = libp2p::gossipsub::Behaviour::new(
            libp2p::gossipsub::MessageAuthenticity::Signed(alice_keypair.clone()),
            crate::p2p::gossipsub::build_gossipsub_config(),
        ).unwrap();

        let mut swarm_a = libp2p::SwarmBuilder::with_existing_identity(alice_keypair)
            .with_tokio()
            .with_tcp(
                libp2p::tcp::Config::default(),
                libp2p::noise::Config::new,
                libp2p::yamux::Config::default,
            ).unwrap()
            .with_behaviour(|_| {
                Ok(P2PChatBehaviour {
                    identify: alice_identify,
                    mdns: alice_mdns,
                    gossipsub: alice_gossipsub,
                    relay_client: alice_relay_client,
                    dcutr: alice_dcutr,
                })
            }).unwrap()
            .build();

        // 2. Generate identity B
        let bob_identity = identity::generate_random_identity().unwrap();
        let bob_keypair = libp2p::identity::Keypair::ed25519_from_bytes(bob_identity.seed).unwrap();
        let bob_peer_id = bob_keypair.public().to_peer_id();

        let (bob_relay_transport, bob_relay_client) = libp2p::relay::client::new(bob_peer_id);
        let bob_dcutr = libp2p::dcutr::Behaviour::new(bob_peer_id);
        let bob_identify = libp2p::identify::Behaviour::new(
            libp2p::identify::Config::new("/p2pchat/1.0.0".to_string(), bob_keypair.public())
        );
        let bob_mdns = libp2p::mdns::tokio::Behaviour::new(
            libp2p::mdns::Config::default(),
            bob_peer_id,
        ).unwrap();
        let bob_gossipsub = libp2p::gossipsub::Behaviour::new(
            libp2p::gossipsub::MessageAuthenticity::Signed(bob_keypair.clone()),
            crate::p2p::gossipsub::build_gossipsub_config(),
        ).unwrap();

        let mut swarm_b = libp2p::SwarmBuilder::with_existing_identity(bob_keypair)
            .with_tokio()
            .with_tcp(
                libp2p::tcp::Config::default(),
                libp2p::noise::Config::new,
                libp2p::yamux::Config::default,
            ).unwrap()
            .with_behaviour(|_| {
                Ok(P2PChatBehaviour {
                    identify: bob_identify,
                    mdns: bob_mdns,
                    gossipsub: bob_gossipsub,
                    relay_client: bob_relay_client,
                    dcutr: bob_dcutr,
                })
            }).unwrap()
            .build();

        // 3. Listen on localhost ports
        swarm_a.listen_on("/ip4/127.0.0.1/tcp/0".parse().unwrap()).unwrap();
        swarm_b.listen_on("/ip4/127.0.0.1/tcp/0".parse().unwrap()).unwrap();

        // 4. Run loop to establish connection via dialing
        let mut alice_connected = false;
        let mut bob_connected = false;
        let mut bob_address = None;

        let timeout = tokio::time::sleep(Duration::from_secs(5));
        tokio::pin!(timeout);

        // Keep the relay transports alive by moving/referencing them in the loop context
        let _keep_alive_alice = alice_relay_transport;
        let _keep_alive_bob = bob_relay_transport;

        loop {
            tokio::select! {
                _ = &mut timeout => {
                    break;
                }
                event = swarm_a.select_next_some() => {
                    if let SwarmEvent::ConnectionEstablished { peer_id, .. } = event {
                        if peer_id == bob_peer_id {
                            alice_connected = true;
                        }
                    }
                }
                event = swarm_b.select_next_some() => {
                    if let SwarmEvent::NewListenAddr { ref address, .. } = event {
                        bob_address = Some(address.clone());
                    }
                    if let SwarmEvent::ConnectionEstablished { peer_id, .. } = event {
                        if peer_id == alice_peer_id {
                            bob_connected = true;
                        }
                    }
                }
            }

            // Once Bob's address is known, dial him from Alice
            if let Some(ref addr) = bob_address {
                if !alice_connected {
                    let _ = swarm_a.dial(addr.clone());
                }
            }

            if alice_connected && bob_connected {
                break;
            }
        }

        assert!(alice_connected && bob_connected, "Nodes failed to connect via loopback network dial");
    }
}
