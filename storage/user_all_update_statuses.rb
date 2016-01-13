# ------------------------ ALL USERS STATUS UPDATES ------------------------
  def self.status_updates # updates status off all template steps for users who have completed them
    User.where.not(ethnicity: nil).each do |user|
      user.form_steps.where(template: 'profile').each do |step|
        user.statuses.where(step_id: step.id).first_or_initialize.update(completed: true, skip_notification: true)
      end
    end

    User.where.not(employer_city: nil).each do |user|
      user.form_steps.where(template: 'employment').each do |step|
        user.statuses.where(step_id: step.id).first_or_initialize.update(completed: true, skip_notification: true)
      end
    end

    User.where.not(guardian_name: nil).each do |user|
      user.form_steps.where(template: 'guardian').each do |step|
        user.statuses.where(step_id: step.id).first_or_initialize.update(completed: true, skip_notification: true)
      end
    end

    User.where.not(physician: nil).each do |user|
      user.form_steps.where(template: 'physician').each do |step|
        user.statuses.where(step_id: step.id).first_or_initialize.update(completed: true, skip_notification: true)
      end
    end

    User.where(references_completed: true).each do |user|
      user.form_steps.where(template: 'references').each do |step|
        user.statuses.where(step_id: step.id).first_or_initialize.update(completed: true, skip_notification: true)
      end
    end

    User.where(id: Reference.all.pluck(:user_id).uniq).each do |user|
      user.form_steps.where(template: 'references').each do |step|
        user.statuses.where(step_id: step.id).first_or_initialize.update(completed: true, skip_notification: true)
      end
    end

    User.where(id: CustomFormResponse.all.pluck(:user_id).uniq).each do |user|
      user.responses.each do |response|
        if step = user.steps.find_by(step_type: 'custom', form_id: response.form_id)
          user.statuses.where(step: step).first_or_initialize.update(completed: true, skip_notification: true)
        end
      end
    end
  end
# ------------------------ END USERS STATUS UPDATES ------------------------