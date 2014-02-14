require 'httparty'

class WeeklyStatsMailer < MandrillMailer::TemplateMailer	
  default from: 'fnz@padm.am'

  def stats(business)
  	ac = ActionController::Base.new()

  	transaction_stats = TransactionStats.new(:business => business)
	renderer = TransactionStatsRenderer.new(:transaction_stats => transaction_stats)
	credits_chart = HTTParty.post('http://fnz-highcharts-api.herokuapp.com/chart_images', body: {input: renderer.credits_chart, width:560})
	debits_chart =  HTTParty.post('http://fnz-highcharts-api.herokuapp.com/chart_images', body: {input: renderer.debits_chart, width:560})
	credits_image = Tempfile.new(['credits_chart', '.png'], :encoding => 'ascii-8bit')
	credits_image.write credits_chart.body
	debits_image = Tempfile.new(['debits_chart', '.png'], :encoding => 'ascii-8bit')
	debits_image.write debits_chart.body
    credits_image.rewind
    debits_image.rewind

    contacts = business.contacts.all_students
    enrollments = business.enrollments.this_month
    sales = business.sales.this_month

    mandrill_mail template: 'weekly-stats',
                  subject: "Weekly Stats",
                  to: { email: business.owner.email, name: business.owner.name },
                  vars: {
                    'business_name' => business.name,
                    'debits_content' => '',
                    'credits_content' => '',
                    'installments_content' => ac.render_to_string(:partial => 'weekly_stats_mailer/installments_sidebar', :locals => {:contacts => contacts}),
                    'enrollments_content' => ac.render_to_string(:partial => 'weekly_stats_mailer/enrollments_content', :locals => {:enrollments => enrollments}),
                    'sales_content' => ac.render_to_string(:partial => 'weekly_stats_mailer/sales_content', :locals => {:sales => sales})
                  },
                  important: true,
                  inline_css: true,
                  images: [
		            {
		                mimetype: "image/png",
		                filename: "credits_chart",
		                file: credits_image.read
		            },
		            {
		                mimetype: "image/png",
		                filename: "debits_chart",
		                file: debits_image.read
		            }
			      ]
  end
end