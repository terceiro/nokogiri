# frozen_string_literal: true

require "helper"

class TestNokogiriPatternMatching < Nokogiri::TestCase
  # rubocop:disable Lint/Syntax
  describe "pattern matching" do
    let(:ns_default) { "http://nokogiri.org/ns/default" }
    let(:ns_noko) { "http://nokogiri.org/ns/noko" }
    let(:xmldoc) do
      Nokogiri::XML::Document.parse(<<~XML)
          <root xmlns="#{ns_default}" xmlns:noko="#{ns_noko}">
            <child1 foo="abc" noko:bar="def" />
            <noko:child2 foo="qwe" noko:bar="rty" />
            <child3>
              <grandchild1 size="small">hello</grandchild1>
              <grandchild2 size="large">goodbye</grandchild2>
            </child3>
          </root>
        XML
    end
    let(:child1) { xmldoc.at_xpath("//a:child1", {"a" => ns_default}) }
    let(:child2) { xmldoc.at_xpath("//b:child2", {"b" => ns_noko}) }
    let(:child3) { xmldoc.at_xpath("//a:child3", {"a" => ns_default}) }
    let(:child1_attr_foo) { xmldoc.at_xpath("//a:child1/@foo", {"a" => ns_default}) }
    let(:child1_attr_bar) { xmldoc.at_xpath("//a:child1/@b:bar", {"a" => ns_default, "b" => ns_noko}) }

    describe "XML::Namespace" do
      it "matches :href" do
        child1.namespace => { href: child1_ns_href }
        assert_equal(ns_default, child1_ns_href)

        child2.namespace => { href: child2_ns_href }
        assert_equal(ns_noko, child2_ns_href)
      end

      it "matches :prefix" do
        child1.namespace => { prefix: child1_ns_prefix }
        assert_nil(child1_ns_prefix)
        
        child2.namespace => { prefix: child2_ns_prefix }
        assert_equal("noko", child2_ns_prefix)
      end
    end

    describe "XML::Attr" do
      it "matches :name" do
        child1_attr_foo => { name: child1_foo_name }
        assert_equal("foo", child1_foo_name)

        child1_attr_bar => { name: child2_bar_name }
        assert_equal("bar", child2_bar_name)
      end

      it "matches :value" do
        child1_attr_foo => { value: child1_foo_value }
        assert_equal("abc", child1_foo_value )

        child1_attr_bar => { value: child1_bar_value }
        assert_equal("def", child1_bar_value)
      end

      it "matches :namespace" do
        child1_attr_foo => { namespace: child1_foo_ns}
        assert_nil(child1_foo_ns)

        child1_attr_bar => { namespace: child1_bar_ns}
        assert_equal(ns_noko, child1_bar_ns.href)
      end
    end

    describe "XML::Node" do
      it "matches :name" do
        child1 => { name: child1_name }
        assert_equal("child1", child1_name)

        child2 => { name: child2_name }
        assert_equal("child2", child2_name)
      end

      it "matches :attributes" do
        ns = ns_noko # so we can pin it

        child1 => { attributes: [*, { name: "foo", value: child1_foo_value }, *] }
        assert_equal("abc", child1_foo_value)

        child1 => { attributes: [*, { namespace: nil, name: "foo", value: child1_foo_value }, *] }
        assert_equal("abc", child1_foo_value)

        child1 => { attributes: [*, { namespace: { href: ^ns }, name: "bar", value: child1_bar_value }, *] }
        assert_equal("def", child1_bar_value)

        child1 => { attributes: [*, { namespace: { href: ^ns }, name: child1_bar_name }, *] }
        assert_equal("bar", child1_bar_name)
      end

      it "matches :namespace" do
        child1 => { namespace: child1_ns }
        assert_equal(ns_default, child1_ns.href)

        child2 => { namespace: child2_ns }
        assert_equal(ns_noko, child2_ns.href)
      end

      it "matches :children" do
        child3 => { children: child3_children }
        assert_equal(5, child3_children.length) # whitespace, gc1, whitespace, gc2, whitespace

        child3 => { children: [*, {name: "grandchild1", content: }, *] }
        assert_equal("hello", content)
      end
    end

    describe "XML::Document" do
      it "matches :root" do
        xmldoc => { root: { name: } }
        assert_equal("root", name)
      end
    end
  end
end
