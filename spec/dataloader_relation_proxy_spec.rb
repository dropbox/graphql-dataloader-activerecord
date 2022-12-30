# frozen_string_literal: true

RSpec.describe DataloaderRelationProxy do
  it 'has a version number' do
    expect(DataloaderRelationProxy::VERSION).not_to be nil
  end

  describe '.defined_for?' do
    before do
      Object.const_set('FooNotRegistered', Class.new)
      Object.const_set('FooRegistered', Class.new)
      subject.define_for!(FooRegistered)
    end

    after do
      Object.send(:remove_const, 'FooRegistered')
      Object.send(:remove_const, 'FooNotRegistered')
    end

    it 'returns false when a proxy is not defined' do
      expect(described_class.defined_for?(FooNotRegistered)).to be(false)
    end

    it 'returns true when a proxy is defined' do
      expect(described_class.defined_for?(FooRegistered)).to be(true)
    end
  end

  describe '.for' do
    let(:subject) { described_class.for(User) }

    it 'returns a proxy class' do
      expect(subject.name).to include('DataloaderRelationProxy::Proxies')
    end

    it 'pretends it is the underlying model class if anyone asks' do
      expect(subject).to be(User)
    end
  end
end
