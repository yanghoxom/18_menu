class CustomersController < ApplicationController
  def index
    customer_params_code = customer_params[:code]

    return if customer_params_code.blank?
    find_customer customer_params_code
  end

  def new
    @customer = Customer.new
  end

  def create
    customer = Customer.new customer_params
    code = nil
    message = nil
    if customer.save
      session[:customer] = customer
      code = 200
      message = t "customer.success_create"
    else
      code = 404
      message = t "customer.fail_create"
    end
    respond_to do |format|
      format.html
      format.json {render json: {code: code,message: message}}
    end
  end

  private

  attr_reader :customer

  def customer_params
    params.require(:customer).permit :name, :email, :phone_num, :code
  end

  def find_customer code
    session[:customer] = Customer.find_by code: code
    session_customer = session[:customer]
    return render json: {status: 0} unless session_customer
    return render json: {status: -1} if session_customer.is_blacklist?
    render json: {status: 1}
  end
end
