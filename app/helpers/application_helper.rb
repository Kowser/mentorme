module ApplicationHelper
  def render_admin_panel(title, partial, options={})
    if current_user.is_partner?
      content_for :panel_title, flush: true do
        title
      end
      content_for :panel_content, flush: true do
        render "admin/#{partial}", options
      end
      render "admin/admin_panel"
    end
  end

  def render_search_panel(partial, options={})
    render "search/search_panel", options.merge(partial: partial)
  end

  def link_to_next_question(f)
    fields = f.fields_for(:questions, f.object.questions.build, child_index: "NQ-#{99999}") do |q|
      render('question', q: q)
    end
    link_to('Next Question', '#', id: 'add-question', data: { id: "NQ-#{99999}", fields: fields.gsub('\n', '') })
  end

  def link_to_next_step(f)
    fields = f.fields_for(:steps, f.object.steps.build, child_index: "NS-#{99999}") do |s|
      render('step', s: s)
    end
    link_to('Next Step', '#', id: 'add-step', data: { id: "NS-#{99999}", fields: fields.gsub('\n', '') })
  end

  def external_link(link)
    link.include?("http") ? link : "#{'http://' + link}"
  end

end
