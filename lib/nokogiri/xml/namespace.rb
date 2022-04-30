# frozen_string_literal: true

module Nokogiri
  module XML
    class Namespace
      include Nokogiri::XML::PP::Node
      attr_reader :document

      def deconstruct_keys(keys)
        { prefix: prefix, href: href }
      end

      private

      def inspect_attributes
        [:prefix, :href]
      end
    end
  end
end
