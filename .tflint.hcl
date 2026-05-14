# Maintainer: Leandro Michelino | ACE | leandro.michelino@oracle.com
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

rule "terraform_unused_declarations" {
  enabled = false
}
