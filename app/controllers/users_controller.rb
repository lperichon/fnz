class UsersController < UserApplicationController
  before_filter :get_context

  def index
    @users = @business.users
  end

  def create
    user = User.find_by_email(params[:user][:email])
    if user
      @business.users << user if user && !@business.users.include?(user)
      redirect_to business_users_path(@business), notice: 'User was successfully added.'
    else
      @users = @business.users
      render action: "index", notice: 'User not found.'
    end
  end

  def destroy
    user = @business.users.find(params[:id])
    @business.users.delete(user) unless @business.owner == user
    redirect_to business_users_path(@business), notice: 'User was successfully removed.'
  end

  private

  def get_context
    business_id = params[:business_id]
    @business = current_user.businesses.find(business_id)
  end

end
