#encoding:utf-8
require "fnordmetric"

FnordMetric.server_configuration = {
  # :redis_url => "redis://localhost:6379",
  # :redis_prefix => "fnordmetric",
  # :inbound_stream => ["0.0.0.0", "1339"],
  # :start_worker => true,
  # :print_stats => 3,

  # events that aren't processed after 2 min get dropped
  # :event_queue_ttl => 120,

  # event data is kept for one month
  # :event_data_ttl => 3600*24*30,
  :event_data_ttl => 30,

  # session data is kept for one month
  # :session_data_ttl => 3600*24*30
}

FnordMetric.namespace :metrics do

# numeric (delta) gauge, 10-min tick
gauge :fps_10_min, 
  :tick => 10.minutes.to_i,
  :average => true,
  :title => "Среднее FPS"

gauge :memory_10_min, 
  :tick => 10.minutes.to_i,
  :average => true,
  :title => "Потребление памяти"

gauge :render_10_min, 
  :tick => 10.minutes.to_i,
  :average => true,
  :title => "Время до рендеринга поля"

gauge :iframe_10_min, 
  :tick => 10.minutes.to_i,
  :average => true,
  :title => "Время от загрузки страницы до старта загрузчика"

gauge :daily_10_min, 
  :tick => 10.minutes.to_i,
  :average => true,
  :title => "Скорость локального обновления"

# on every event like { _type: 'fps' }
event(:performance_vk) do
  [:fps, :memory, :render, :iframe, :daily].each do |t|
    incr "#{t}_10_min".to_sym, data[t] if data[t]
  end
end

# draw a timeline showing the gauges value, auto-refresh every 1s

{
  "Average FPS" => :fps_10_min, 
  "Average memory" => :memory_10_min, 
  "Average render" => :render_10_min,
  "Average iframe" => :iframe_10_min,  
  "Average local update" => :daily_10_min
}.each do |name, gauge|
  widget 'Performance Stats', {
    :title => name,
    :type => :timeline,
    :gauges => gauge,  
    :include_current => true,
    :width => 50,
    :autoupdate => 1
    # :ticks => 144
  }
end

end

FnordMetric.standalone