class SkiesController < ApplicationController
  before_filter :find_resources, only: :index

  def index
  end

  private

  def find_resources
    @resources ||= Sky.order(created_at: :desc)
  end
end
