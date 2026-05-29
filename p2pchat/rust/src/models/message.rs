use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct MessageEnvelope {
    pub v: u8,                          // protocol version = 1
    pub id: String,                     // UUID v4
    pub msg_type: MessageType,          // chat | ack | presence | group_invite | key_exchange
    pub sender: String,                 // PeerID sender
    pub timestamp: u64,                 // Unix ms
    pub payload: EncryptedPayload,
    pub sig: String,                    // base64 Ed25519 signature
}

#[derive(Serialize, Deserialize, Clone, Copy, Debug, PartialEq, Eq)]
pub enum MessageType {
    Chat,
    Ack,
    Presence,
    GroupInvite,
    KeyExchange,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
#[serde(tag = "type", content = "data")]
pub enum EncryptedPayload {
    Dm(DMPayload),
    Group(GroupPayload),
    None,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct DMPayload {
    pub nonce: String,                  // base64 24-byte nonce
    pub ciphertext: String,             // base64 NaCl box encrypted
    pub sender_pub_key: String,         // base64 X25519 pub key
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct GroupPayload {
    pub group_id: String,
    pub nonce: String,                  // base64 24-byte nonce
    pub ciphertext: String,             // base64 NaCl secretbox encrypted
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ChatMessage {
    pub content: String,
    pub content_type: ContentType,      // text | image | file | voice
    pub reply_to_id: Option<String>,
    pub metadata: Option<serde_json::Value>,
}

#[derive(Serialize, Deserialize, Clone, Copy, Debug, PartialEq, Eq)]
pub enum ContentType {
    Text,
    Image,
    File,
    Voice,
}

impl MessageEnvelope {
    pub fn sign(&mut self, signing_key: &ed25519_dalek::SigningKey) -> anyhow::Result<()> {
        use ed25519_dalek::Signer;
        self.sig = "".to_string();
        let bytes = serde_json::to_vec(self)?;
        let signature = signing_key.sign(&bytes);
        self.sig = base64::Engine::encode(&base64::prelude::BASE64_STANDARD, &signature.to_bytes());
        Ok(())
    }

    pub fn verify(&self, public_key_bytes: &[u8; 32]) -> bool {
        use ed25519_dalek::Verifier;
        let mut envelope_copy = self.clone();
        envelope_copy.sig = "".to_string();
        let bytes_res = serde_json::to_vec(&envelope_copy);
        if let Ok(bytes) = bytes_res {
            if let Ok(sig_bytes) = base64::Engine::decode(&base64::prelude::BASE64_STANDARD, &self.sig) {
                if let Ok(sig_array) = sig_bytes.try_into() {
                    let signature = ed25519_dalek::Signature::from_bytes(&sig_array);
                    if let Ok(verifying_key) = ed25519_dalek::VerifyingKey::from_bytes(public_key_bytes) {
                        return verifying_key.verify(&bytes, &signature).is_ok();
                    }
                }
            }
        }
        false
    }
}
