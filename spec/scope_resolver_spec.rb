require "spec_helper"

module Pundit
  describe ScopeResolver do
    subject { described_class.new(user, resource_scope) }
    let(:user) { double('pundit_user') }

    describe '#resolve' do
      context 'policy class cannot be found' do
        let(:resource_scope) { nil }

        it { expect(subject.resolve).to be nil }
      end

      context 'policy class with not a defined Scope class' do
        let(:resource_scope) { None }

        before {
          expect("#{resource_scope}Policy".safe_constantize).to be_present
          expect("#{resource_scope}Policy::Scope".safe_constantize).to_not be_present
        }

        it { expect(subject.resolve).to be nil }
      end

      context 'policy class with a defined Scope class' do
        let(:resource_scope) { Post }

        before {
          expect("#{resource_scope}Policy".safe_constantize).to be_present
          expect("#{resource_scope}Policy::Scope".safe_constantize).to be_present
        }

        it { expect(subject.resolve).to eq :published }
      end

      context 'namespaced resource scope' do
        let(:resource_scope) { [:admin, Post] }

        it { expect(subject.resolve).to eq :published }
      end
    end

    describe '#resolve!' do
      context 'policy class cannot be found' do
        let(:resource_scope) { nil }

        it { expect{subject.resolve!}.to raise_error(Pundit::NotDefinedError, /unable to find policy scope of nil/) }
      end

      context 'policy class with not a defined Scope class' do
        let(:resource_scope) { None }

        before {
          expect("#{resource_scope}Policy".safe_constantize).to be_present
          expect("#{resource_scope}Policy::Scope".safe_constantize).to_not be_present
        }

        it { expect{subject.resolve!}.to raise_error(Pundit::NotDefinedError, /unable to find Scope class for `#{resource_scope}Policy`/) }
      end

      context 'policy class with a defined Scope class' do
        let(:resource_scope) { Post }

        before {
          expect("#{resource_scope}Policy".safe_constantize).to be_present
          expect("#{resource_scope}Policy::Scope".safe_constantize).to be_present
        }

        it { expect(subject.resolve!).to eq :published }
      end

      context 'namespaced resource scope' do
        let(:resource_scope) { [:admin, Post] }

        it { expect(subject.resolve!).to eq :published }
      end
    end
  end
end
