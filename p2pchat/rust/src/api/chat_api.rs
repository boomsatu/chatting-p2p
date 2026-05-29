use crate::frb_generated::StreamSink;
use once_cell::sync::Lazy;
use std::sync::RwLock;

pub static MESSAGE_SINK: Lazy<RwLock<Option<StreamSink<String>>>> = Lazy::new(|| RwLock::new(None));

pub fn register_message_stream(sink: StreamSink<String>) -> Result<(), String> {
    let mut write_lock = MESSAGE_SINK.write().unwrap();
    *write_lock = Some(sink);
    Ok(())
}

pub fn get_message_sink() -> Option<StreamSink<String>> {
    let read_lock = MESSAGE_SINK.read().unwrap();
    read_lock.clone()
}

pub async fn send_dm(
    target_peer_id: String,
    target_pub_key: String, // base64 X25519 public key
    content: String,
) -> Result<String, String> {
    // 1. Get our own keys and PeerID
    let my_keys = crate::crypto::keystore::get_identity_keys()
        .ok_or_else(|| "Identity keys not set".to_string())?;
    
    // 2. Build the ChatMessage
    let chat_msg = crate::models::message::ChatMessage {
        content: content.clone(),
        content_type: crate::models::message::ContentType::Text,
        reply_to_id: None,
        metadata: None,
    };
    let chat_msg_bytes = serde_json::to_vec(&chat_msg)
        .map_err(|e| e.to_string())?;

    // 3. Encrypt payload
    let recipient_pub_bytes = base64::Engine::decode(&base64::prelude::BASE64_STANDARD, &target_pub_key)
        .map_err(|e| e.to_string())?;
    let recipient_pub_array: [u8; 32] = recipient_pub_bytes.try_into()
        .map_err(|_| "Invalid recipient public key length".to_string())?;

    let my_secret = crate::crypto::keystore::get_box_secret()
        .map_err(|e| e.to_string())?;
    let my_secret_bytes = my_secret.to_bytes();

    let (ciphertext, nonce) = crate::crypto::dm_crypto::encrypt_dm(
        &chat_msg_bytes,
        &recipient_pub_array,
        &my_secret_bytes,
    ).map_err(|e| e.to_string())?;

    let dm_payload = crate::models::message::DMPayload {
        nonce: base64::Engine::encode(&base64::prelude::BASE64_STANDARD, &nonce),
        ciphertext: base64::Engine::encode(&base64::prelude::BASE64_STANDARD, &ciphertext),
        sender_pub_key: base64::Engine::encode(&base64::prelude::BASE64_STANDARD, &my_keys.box_pubkey),
    };

    // 4. Create MessageEnvelope
    let timestamp = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_millis() as u64;

    let message_id = uuid::Uuid::new_v4().to_string();

    let mut envelope = crate::models::message::MessageEnvelope {
        v: 1,
        id: message_id.clone(),
        msg_type: crate::models::message::MessageType::Chat,
        sender: my_keys.peer_id.clone(),
        timestamp,
        payload: crate::models::message::EncryptedPayload::Dm(dm_payload),
        sig: "".to_string(),
    };

    // 5. Sign the envelope
    let signing_key = crate::crypto::keystore::get_signing_key()
        .map_err(|e| e.to_string())?;
    envelope.sign(&signing_key).map_err(|e| e.to_string())?;

    // 6. Publish to GossipSub
    let topic = crate::p2p::topics::dm_topic(&my_keys.peer_id, &target_peer_id);
    let envelope_bytes = serde_json::to_vec(&envelope)
        .map_err(|e| e.to_string())?;

    crate::p2p::node::publish(topic, envelope_bytes).await?;

    Ok(message_id)
}
