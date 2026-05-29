use crate::p2p::node;

pub async fn connect_peer(multiaddr: String) -> Result<(), String> {
    node::dial(multiaddr).await
}
