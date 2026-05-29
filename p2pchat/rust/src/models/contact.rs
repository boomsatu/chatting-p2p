use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ContactCard {
    pub peer_id: String,
    pub display_name: String,
    pub pub_key: String,       // base64 X25519 public key
    pub sign_pub_key: String,  // base64 Ed25519 public key
    pub multiaddrs: Vec<String>,
    pub avatar_uri: Option<String>,
}
