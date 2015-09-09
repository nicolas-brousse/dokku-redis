#!/usr/bin/env bats
load test_helper

setup() {
  export ECHO_DOCKER_COMMAND="false"
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  export ECHO_DOCKER_COMMAND="false"
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:connect) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:connect"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:connect) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:connect" not_existing_service
  assert_contains "${lines[*]}" "Redis service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:connect) success" {
  export ECHO_DOCKER_COMMAND="true"
  run dokku "$PLUGIN_COMMAND_PREFIX:connect" l
  assert_output 'docker run -it --link dokku.redis.l:redis --rm redis sh -c exec redis-cli -h "$REDIS_PORT_6379_TCP_ADDR" -p "$REDIS_PORT_6379_TCP_PORT"'
}

