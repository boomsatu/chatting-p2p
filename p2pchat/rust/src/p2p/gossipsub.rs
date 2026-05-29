use libp2p::gossipsub;

pub fn build_gossipsub_config() -> gossipsub::Config {
    gossipsub::ConfigBuilder::default()
        .mesh_n(6)
        .mesh_n_low(4)
        .mesh_n_high(12)
        .gossip_factor(0.25)
        .heartbeat_interval(std::time::Duration::from_secs(1))
        .history_length(6)
        .history_gossip(3)
        .max_transmit_size(65536)
        .flood_publish(true)
        .build()
        .expect("Valid gossipsub config")
}
