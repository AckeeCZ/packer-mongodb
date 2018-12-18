# Ackee MongoDB GCE Packer templates with Stackdriver integration

This [Packer](https://www.packer.io/) image template is designed to be run inside [GCE](https://cloud.google.com/compute/). It is based upon Ubuntu 16.04 image from Google with Stackdriver monitoring and logging([google-fluentd](https://cloud.google.com/logging/docs/agent/)) agents preinstalled.

This image should be orchestrated by [Ackee MongoDB Terraform module](https://github.com/AckeeDevOps/terraform-mongodb)
