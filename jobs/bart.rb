require 'bart/station'


#station abbreviations you want departure estimates for.
#You can also specify direction and platform according to the BART api
#(http://api.bart.gov/docs/etd/etd.aspx)
#ex: {abbr: "mlbr", plat: 1}
#    {abbr: "embr", dir: "s"}
DEPART_STATION = {abbr: "embr", dir: "s"}
#Filter the list of destination estimates from the depart stations to the following stations
DESTINATION_STATIONS = ["mlbr", "sfia"]

UPDATE = '5m' #This is how often we query the BART API. Don't be a jerk and do it too often...
UPDATE_DISPLAY = '10s' #This is how often we update the display on the dashboard.


class BartEstimate

  def initialize (options)
    @depart_station = options[:depart_station]
    @destination_stations = options[:destination_stations]
    @destination_index = 0
    @dest_estimates = Array.new
    @last_updated = Time.now
  end


  #Handles fetching from the Bart API
  def fetch_destination_estimates
    #create the station object
    station = Bart::Station.new(abbr:@depart_station[:abbr])
    #load the departures passing any extra parameters
    params = @depart_station.select {|k| [:plat, :dir].include?(k)}
    departures = station.load_departures(params)

    #filter the departures to our destinations
    if @destination_stations.length > 0
      @dest_estimates = departures.select { |d| @destination_stations.include?(d.destination.abbr) }
    else
      @dest_estimates = departures
    end

    @last_updated = Time.now
  end

  #Formats and returns a single destination ready for the front end.
  def get_destination
    if @dest_estimates.length > 0
      @destination_index = 0 if @destination_index >= @dest_estimates.length
      destination = Hash.new
      dest = @dest_estimates[@destination_index]
      destination[:abbr] = dest.destination.abbr
      destination[:station_name] = dest.destination.name
      destination[:estimates] = Array.new
      dest.estimates.each do |e|
        #get the difference since the last update in seconds
        minutes_since = ((Time.now - @last_updated)/60).round
        #only add to the estimates if the train hasn't departed yet
        if minutes_since <= e.minutes
          destination[:estimates] << {:minutes => (e.minutes - minutes_since), :train_length => e.length}
        end
      end
      @destination_index += 1
      destination
    end

  end
end

#Create our BartEstimate with the values and call bart
@BartEst = BartEstimate.new({depart_station: DEPART_STATION, destination_stations: DESTINATION_STATIONS})
@BartEst.fetch_destination_estimates
#Send the first event
send_event('bart', destination: @BartEst.get_destination)


#This queries the BART API
SCHEDULER.every UPDATE, :first_in => 0 do |job|
  @BartEst.fetch_destination_estimates
end

#This sends the data to the front end. It accounts for time since update
SCHEDULER.every UPDATE_DISPLAY, :first_in => 1 do |job|
  send_event('bart', destination: @BartEst.get_destination)
end