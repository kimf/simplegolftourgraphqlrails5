class StandardCompetitionRankings

  def initialize(data, options = {})
    @data = data
    @options = options.reverse_merge(sort_direction: :desc, set: :position)
  end

  def sort_data!
    return if @options[:sort_direction].nil? or @options[:sort_direction] == false

    if @options[:dealbreaker].nil?
      case @options[:sort_direction]
      when :desc then @data.sort! {|a, b| b.send(@options[:rank_by]) <=> a.send(@options[:rank_by]) }
      when :asc  then @data.sort! {|a, b| a.send(@options[:rank_by]) <=> b.send(@options[:rank_by]) }
      else raise ArgumentError, "Sort direction can only be :asc or :desc"
      end
    else
      case @options[:sort_direction]
      when :desc then @data.sort! {|a, b| [b.send(@options[:rank_by]), b.send(@options[:dealbreaker])] <=> [a.send(@options[:rank_by]), a.send(@options[:dealbreaker])] }
      when :asc  then @data.sort! {|a, b| [a.send(@options[:rank_by]), a.send(@options[:dealbreaker])] <=> [b.send(@options[:rank_by]), b.send(@options[:dealbreaker])] }
      else raise ArgumentError, "Sort direction can only be :asc or :desc"
      end
    end
  end

  def calculate
    return @rankings if @rankings.present?

    @rankings = []

    sort_data!

    @data.each_with_index do |data, i|
      if i == 0
        data.send("#{@options[:set]}=", 1)
      elsif data.send(@options[:rank_by]) == @data[i-1].send(@options[:rank_by])
        unless @options[:dealbreaker].nil?
          if (data.send(@options[:dealbreaker]) == @data[i-1].send(@options[:dealbreaker]))
            data.send("#{@options[:set]}=", @rankings[i-1].send(@options[:set]))
          else
            data.send("#{@options[:set]}=", i + 1)
            @rankings[i] = data
          end
        else
          data.send("#{@options[:set]}=", @rankings[i-1].send(@options[:set]))
        end

      else
        data.send("#{@options[:set]}=", i + 1)
      end
      @rankings[i] = data
    end

    @rankings
  end

end
