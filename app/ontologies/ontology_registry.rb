module OntologyRegistry
  module_function

  def all
    Ontology.subclasses.map(&:instance)
  end

  def topics
    all.flat_map { |ontology| ontology.respond_to?(:all_topics) ? ontology.all_topics : [] }.uniq
  end

  def operations
    all.flat_map { |ontology| ontology.respond_to?(:all_operations) ? ontology.all_operations : [] }.uniq
  end

  def lookup_term(uri)
    all.find { |ontology| ontology.term_uri_matches?(uri) }&.lookup(uri)
  end
end