require 'ddtrace/profiling/trace_identifiers/helper'
require 'ddtrace/profiling/trace_identifiers/ddtrace'

RSpec.describe Datadog::Profiling::TraceIdentifiers::Helper do
  let(:thread) { instance_double(Thread) }
  let(:api1) { instance_double(Datadog::Profiling::TraceIdentifiers::Ddtrace, 'api1') }
  let(:api2) { instance_double(Datadog::Profiling::TraceIdentifiers::Ddtrace, 'api2') }

  subject(:trace_identifiers_helper) { described_class.new(supported_apis: [api1, api2]) }

  describe '#trace_identifiers_for' do
    subject(:trace_identifiers_for) { trace_identifiers_helper.trace_identifiers_for(thread) }

    context 'when the first api provider returns trace identifiers' do
      before do
        allow(api1).to receive(:trace_identifiers_for).and_return([:api1_trace_id, :api1_span_id])
      end

      it 'returns the first api provider trace identifiers' do
        expect(trace_identifiers_for).to eq [:api1_trace_id, :api1_span_id]
      end

      it 'does not attempt to read trace identifiers from the second api provider' do
        expect(api2).to_not receive(:trace_identifiers_for)

        trace_identifiers_for
      end
    end

    context 'when the first api provider does not return trace identifiers, but the second one does' do
      before do
        allow(api1).to receive(:trace_identifiers_for).and_return(nil)
        allow(api2).to receive(:trace_identifiers_for).and_return([:api2_trace_id, :api2_span_id])
      end

      it 'returns the second api provider trace identifiers' do
        expect(trace_identifiers_for).to eq [:api2_trace_id, :api2_span_id]
      end
    end

    context 'when no api providers return trace identifiers' do
      before do
        allow(api1).to receive(:trace_identifiers_for).and_return(nil)
        allow(api2).to receive(:trace_identifiers_for).and_return(nil)
      end

      it do
        expect(trace_identifiers_for).to be nil
      end
    end
  end
end