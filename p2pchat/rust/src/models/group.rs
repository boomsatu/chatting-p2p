use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct GroupInfo {
    pub id: String, // UUID v4
    pub name: String,
    pub topic: String,
    pub admin_peer_id: String,
    pub members: Vec<String>, // list of PeerIDs
}
