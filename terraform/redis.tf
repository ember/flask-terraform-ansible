resource "aws_elasticache_subnet_group" "private" {
  name       = "subnet-group-${var.app_name}"
  subnet_ids = ["${aws_subnet.private_az1.id}", "${aws_subnet.private_az2.id}"]
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "cluster-${var.app_name}"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  port                 = 6379
  subnet_group_name    = "${aws_elasticache_subnet_group.private.name}"
  security_group_ids   = ["${aws_security_group.redis.id}"]

  tags {
    Name = "redis-${var.app_name}"
  }
}
