class TransactionStatsRenderer
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :transaction_stats

  validates :transaction_stats, :presence => true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def debits_chart
    debits = transaction_stats.debits
    untagged_debits = transaction_stats.untagged_debits

    render_chart "Debits", debits, untagged_debits
  end


  def credits_chart
    credits = transaction_stats.credits
    untagged_credits = transaction_stats.untagged_credits

    render_chart "Credits", credits, untagged_credits
  end

  private

  def render_chart(name, tagged, untagged)
    chart_json = %(
      {
        chart: {
            renderTo: "#{name.downcase}_chart",
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false
        },
        title: {
            text: "#{name}: $#{tagged.values.sum.to_f.round(2)}"
        },
        tooltip: {
            pointFormat: '<b>{point.y}</b>',
            valueDecimals: 2,
            valuePrefix: '$'
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    color: '#000000',
                    connectorColor: '#000000',
                    formatter: function() {
                        return '<b>'+ this.point.name +'</b>: $'+ this.y;
                    }
                }
            }
        },
        series: [{
            type: 'pie',
            name: '#{name}',
            data: [
    )

    tagged.each do |tag, sum|
      chart_json << "['#{tag}', #{sum.to_f.round(2) }],"
    end
    
    if untagged > 0
      chart_json << "['Untagged', #{untagged.to_f.round(2)}],"
    end

    chart_json << %(
            ]
        }]
      }
    )

    chart_json
  end
end
