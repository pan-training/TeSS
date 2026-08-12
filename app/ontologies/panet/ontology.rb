module Panet
  class Ontology < ::Ontology
    include Singleton
    ALT_IN_SUBSET = RDF::URI('http://purl.obolibrary.org/obo/inSubset').freeze

    def initialize
      super('PaNET.owl', Panet::Term)
    end

    def uri
      'http://purl.org/pan-science/PaNET/'
    end

    def all_topics
      [find_by(OBO.inSubset, EDAM.topics),
       find_by(ALT_IN_SUBSET, EDAM.topics)].flatten.uniq
    end

    def lookup_by_name(name)
      lookup_by(RDF::RDFS.label, name)
    end

    def scoped_lookup_by_name(name, subset = :_)
      query = RDF::Query.new do
        pattern [:u, RDF::RDFS.label, name]
        pattern [:u, OBO.inSubset, subset]
      end

      result = graph.query(query).first
      unless result
        fallback_query = RDF::Query.new do
          pattern [:u, RDF::RDFS.label, name]
          pattern [:u, ALT_IN_SUBSET, subset]
        end
        result = graph.query(fallback_query).first
      end
      lookup(result.u) if result
    end

    def scoped_lookup_by_name_or_synonym(name, subset = :_)
      out = scoped_lookup_by_name(name, subset)
      return out unless out.blank?

      out = find_by(OBO.hasExactSynonym, name)
      return out unless out.blank?

      find_by(OBO.hasNarrowSynonym, name)
    end
  end
end