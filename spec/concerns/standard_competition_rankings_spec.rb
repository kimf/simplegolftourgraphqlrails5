require 'spec_helper'

describe StandardCompetitionRankings do

  let!(:sample_data) do
    sample_data = []
    %w(1000 2000 3000 3000 4000 5000 6000 7000 7000 9000).each do |points|
      sample_data << FactoryGirl.create(:score, points: points)
    end
    sample_data
  end

  describe '#calculate' do
    it "should produce rankings with correctly calculated tied positions, sorted ascending" do
      scr = StandardCompetitionRankings.new(sample_data, rank_by: :points, sort_direction: :asc)

      rankings = scr.calculate.map {|r| r.position }
      rankings.should == [1, 2, 3, 3, 5, 6, 7, 8, 8, 10]
    end

    it "should produce rankings with correctly calculated tied positions, sorted descending" do
      scr = StandardCompetitionRankings.new(sample_data, rank_by: :points, sort_direction: :desc)

      rankings = scr.calculate.map {|r| r.position }
      rankings.should == [1, 2, 2, 4, 5, 6, 7, 7, 9, 10]
    end
  end

  context "with dealbraker" do

    let!(:sample_data) do
      sample_data = []
      [[1,1], [2,2], [2, 2], [2, 1], [3,1], [4,1], [4,2]].each do |a|
        sample_data << Struct.new(:points, :average, :position).new(a[0], a[1], nil)
      end
      sample_data
    end

    describe '#calculate' do
      it "should produce rankings with correctly calculated tied positions, sorted ascending" do
        scr = StandardCompetitionRankings.new(sample_data, rank_by: :points, dealbreaker: :average, sort_direction: :asc)

        rankings = scr.calculate.map {|r| r.position }
        rankings.should == [1, 2, 3, 3, 5, 6, 7]
      end

      it "should produce rankings with correctly calculated tied positions, sorted descending" do
        scr = StandardCompetitionRankings.new(sample_data, rank_by: :points, dealbreaker: :average, sort_direction: :desc)

        rankings = scr.calculate.map {|r| r.position }
        rankings.should == [1, 2, 3, 4, 4, 6, 7]
      end
    end


  end
end
