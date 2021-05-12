require 'ddtrace/tracing/runtime'

module Datadog
  # Manages the {Runtime} life cycle for the host application.
  #
  # The {Runtime} is a container of all stateful tracer internals.
  #
  # {LifeCycle} ensure that the {Runtime} is created,
  # modified and decommissioned correctly during the host
  # application's life cycle.
  module LifeCycle
    extend Forwardable

    def_delegators \
        :runtime,
        :configure, :shutdown!,
        :configuration,
        :health_metrics, :logger, :profiler, :runtime_metrics, :tracer

    protected

    def start!(runtime = Tracing::Runtime.new)
      @runtime = runtime
      runtime.startup!
    end

    private

    attr_reader :runtime

    # Only used internally for testing
    def restart!
      shutdown!
      registry.reset!

      @runtime = nil

      start!
    end
  end
end
