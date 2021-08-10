require 'rake'

describe 'cookie.rake', experiments: true do
  before do
    Rake.application.rake_require "tasks/cookie"
    Rake::Task.define_task(:environment)
  end

  describe 'eeny_meeny:cookie:experiment' do
    context 'executed with an experiment id' do
      it 'generates a cookie' do
        expect {
          Rake::Task['eeny_meeny:cookie:experiment'].execute(Rake::TaskArguments.new([:experiment_id],['my_page']))
        }.to_not raise_error
      end
    end

    context 'executed without arguments' do
      it 'results in an error' do
        expect {
          Rake::Task['eeny_meeny:cookie:experiment'].execute
        }.to raise_error(RuntimeError, "Missing 'experiment_id' parameter")
      end
    end
  end

  describe 'eeny_meeny:cookie:experiment_variation' do
    context 'executed with an experiment id' do
      it 'results in an error' do
        expect {
          Rake::Task['eeny_meeny:cookie:experiment_variation'].execute(Rake::TaskArguments.new([:experiment_id],['my_page']))
        }.to raise_error(RuntimeError, "Missing 'variation_id' parameter")
      end

      context 'and a variation_id' do
        it 'generates a cookie' do
          expect {
            Rake::Task['eeny_meeny:cookie:experiment_variation'].execute(Rake::TaskArguments.new([:experiment_id, :variation_id],['my_page', 'new']))
          }.to_not raise_error
        end
      end
    end

    context 'executed without arguments' do
      it 'results in an error' do
        expect {
          Rake::Task['eeny_meeny:cookie:experiment_variation'].execute
        }.to raise_error(RuntimeError, "Missing 'experiment_id' parameter")
      end
    end
  end

  describe 'eeny_meeny:cookie:smoke_test' do
    context 'executed with an smoke test id' do
      it 'generates a cookie' do
        expect {
          Rake::Task['eeny_meeny:cookie:smoke_test'].execute(Rake::TaskArguments.new([:smoke_test_id],['shadow']))
        }.to_not raise_error
      end
    end

    context 'executed without arguments' do
      it 'results in an error' do
        expect {
          Rake::Task['eeny_meeny:cookie:smoke_test'].execute
        }.to raise_error(RuntimeError, "Missing 'smoke_test_id' parameter")
      end
    end
  end

end
