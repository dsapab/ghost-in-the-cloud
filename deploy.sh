#!/bin/env bash

cd infra && terraform plan && terraform apply --auto-approve
