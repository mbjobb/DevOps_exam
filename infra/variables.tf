variable "candidate_prefix"{
    type = string
    default = "knr14"
}

variable "output_bucket_name" {
    type = string
    default = "pgr301-couch-explorers"
}

variable "alarm_email" {
    type = string
}