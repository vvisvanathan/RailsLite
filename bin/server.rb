require 'active_support'
require 'active_support/core_ext'
require 'webrick'
require 'byebug'
require_relative '../lib/db_connection'
require_relative '../lib/sql_object'
require_relative '../lib/controller_base'
require_relative '../lib/router'

class Cat < SQLObject
  belongs_to :owner, class_name: 'Human'
end

class Human < SQLObject
  has_many :cats
end

class CatsController < ControllerBase
  def show
  end

  def index
    @cats = cats.all
    render :index
  end

  def new
    @cat = Cat.new
    render :new
  end

  def create
    @cat = Cat.new(params["cat"])
    if @cat.save
      redirect_to("/cats")
    else
      render :new
    end
  end
end

DBConnection.reset

router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/new$"), CatsController, :new
  get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
  post Regexp.new("^/cats$"), CatsController, :create
end

trap('INT') { server.shutdown }
server.start
