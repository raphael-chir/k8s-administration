# ----------------------------------------
#    Default main config - Staging env
# ----------------------------------------

region_target = "eu-west-3"

resource_tags = {
  project     = "k8s"
  environment = "staging"
  owner       = "raphael.chir@couchbase.com"
  user        = "raphael.chir@couchbase.com"
}

ssh_public_key_path = ".ssh/id_rsa.pub"
ssh_private_key_path = ".ssh/id_rsa"
key_pair_name = "k8s-rch-kp"
