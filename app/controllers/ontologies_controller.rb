# The controller for actions related to ontology autocompletion terms.
class OntologiesController < ApplicationController

  skip_before_action :authenticate_user!, :authenticate_user_from_token!

  def terms
    list(OntologyRegistry.topics + OntologyRegistry.operations)
  end

  def operations
    list(OntologyRegistry.operations)
  end

  def topics
    list(OntologyRegistry.topics)
  end

  private

  def list(terms)
    @terms = terms

    if filter_param
      @terms = @terms.select { |t| t.preferred_label.downcase.start_with?(filter_param.downcase) }
    end

    render 'ontologies/index', format: :json
  end

  def filter_param
    if params[:filter].present?
      params[:filter]
    elsif params[:q].present?
      params[:q].chomp('*') # Chop off the * appended automatically by the autocompleter
    end
  end

end