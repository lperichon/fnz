require 'httparty'

class WeeklyStatsMailer < MandrillMailer::TemplateMailer
  default from: 'fnz@padm.am'

  def stats(business)
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
    mandrill_mail template: 'weekly-stats',
                  subject: "Weekly Stats",
                  to: { email: business.owner.email, name: business.owner.name },
                  vars: {
                    'business_name' => business.name,
                    'debits_content' => '',
                    'credits_content' => ''
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