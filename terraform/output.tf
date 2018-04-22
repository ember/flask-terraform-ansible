output "elb_address" {
  value = "${aws_elb.elb_app.dns_name}"
}

output "redis_endpoint" {
  value = "${join(":", list(aws_elasticache_cluster.redis.cache_nodes.0.address, aws_elasticache_cluster.redis.cache_nodes.0.port))}"
}
