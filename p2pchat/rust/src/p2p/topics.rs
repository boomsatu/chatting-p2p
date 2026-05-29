pub fn dm_topic(peer_a: &str, peer_b: &str) -> String {
    let mut peers = [peer_a.to_string(), peer_b.to_string()];
    peers.sort();
    format!("dm:{}:{}", peers[0], peers[1])
}

pub fn group_topic(group_id: &str) -> String {
    format!("group:{}", group_id)
}

pub fn presence_topic(peer_id: &str) -> String {
    format!("presence:{}", peer_id)
}

pub fn invite_topic(target_peer_id: &str) -> String {
    format!("invite:{}", target_peer_id)
}
