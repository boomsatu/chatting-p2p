use libp2p::Multiaddr;

pub struct RelayManager;

impl RelayManager {
    /// Returns a list of known stable public libp2p bootstrap/relay multiaddresses.
    /// Useful as circuit relay nodes for NAT traversal and direct hole punching.
    pub fn get_public_relays() -> Vec<String> {
        vec![
            "/ip4/147.75.109.213/tcp/4001/p2p/QmNnoo2EsWamkPyapEc4Q4qZGo1FmWXw84D5yD4ML75v9N".to_string(),
            "/ip4/147.75.80.39/tcp/4001/p2p/QmQCU2b7TrfCHaaPMLvzDNPEea2kCNdE1WCDJaubhE6C1g".to_string(),
        ]
    }

    /// Derives the standard circuit relay multiaddress required to establish routed P2P connections
    /// through a specific intermediary relay node to a targeted destination peer.
    pub fn derive_circuit_address(relay_addr: &str, target_peer_id: &str) -> Result<Multiaddr, String> {
        let circuit_str = format!("{}/p2p-circuit/p2p/{}", relay_addr, target_peer_id);
        circuit_str.parse::<Multiaddr>().map_err(|e| e.to_string())
    }
}
