class CourseCompletionMailer < ApplicationMailer
  def completed_course_email
    @user = params[:user]
    @completed_course = params[:course]
    @unions = user_unions(@user)
    @union_count = @unions.count

    @courses_by_union = @unions.index_with do |union|
      union.course_lists.order(:position, :title)
    end

    mail(
      to: @user.email,
      subject: "You have successfully completed the course"
    )
  end

  private

  def user_unions(user)
    unions = user.unions
    unions = Union.where(id: user.union_id) if unions.empty? && user.union_id.present?
    unions.distinct.order(:name)
  end
end
