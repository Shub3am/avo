require "rails_helper"

RSpec.describe "Go back from a belongs_to index link", type: :system do
  describe "from a resource index" do
    let!(:course_link) { create :course_link }

    it "returns to the index the link was clicked on" do
      visit "/admin/resources/course_links"

      field_element_by_resource_id("course", course_link.to_param).find("a").click
      wait_for_loaded

      expect(page).to have_current_path(/\/admin\/resources\/courses\/#{course_link.course.to_param}/)

      click_on "Go back"
      wait_for_loaded

      expect(page).to have_current_path "/admin/resources/course_links"
    end
  end

  describe "from an association frame on a show page" do
    let!(:project) { create :project }
    let!(:user) { create :user }
    let!(:review) { create :review, reviewable: project, user: user }

    it "keeps going back to the target resource index" do
      visit "/admin/resources/projects/#{project.id}"

      reviews_frame = has_many_field_wrapper(id: :reviews)
      scroll_to reviews_frame
      # The page is short, so scrolling pulls every lazy association frame into view at once.
      # They finish in any order and each one grows, which moves the link, so wait for all of them.
      expect(page).to have_no_css("turbo-frame[src]:not([complete])")

      within(reviews_frame) do
        user_link = field_element_by_resource_id("user", review.to_param).find("a")
        expect(user_link[:href]).not_to include("return_to")
        user_link.click
      end
      wait_for_loaded

      expect(page).to have_current_path(/\/admin\/resources\/users\/#{user.to_param}/)

      click_on "Go back"
      wait_for_loaded

      expect(page).to have_current_path "/admin/resources/users"
    end
  end
end
