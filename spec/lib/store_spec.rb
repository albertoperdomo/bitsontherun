require 'spec_helper'

describe "API call to store new video file" do
  it_should_behave_like "Successful response"

  before do
    @responses = []
    @file = 'spec/test.mp4'
    @responses << BitsOnTheRun::store('videos/create', @file)

    @manual = BitsOnTheRun::API.new(:store)
    @manual.method('videos/create')
    @manual.file(@file)
    @responses << @manual.execute
  end

  after do
    @responses.each do |video|
      BitsOnTheRun::call('videos/delete', :video_key => video.media.key)
    end
  end

  it "should contain information about uploaded video" do
    @responses.each do |r|
      r.file(:md5).size.should eql(32)
      r.file(:size).to_i.should > 0
    end
  end
end

describe "API call to store create new empty video object without uploading" do
  it_should_behave_like "Successful response"

  before do
    @responses = []
    @responses << BitsOnTheRun::store('videos/create')

    @manual = BitsOnTheRun::API.new(:store)
    @manual.method('videos/create')
    @responses << @manual.execute
  end

  after do
    @responses.each do |video|
      BitsOnTheRun::call('videos/delete', :video_key => video.media.key)
    end
  end

  it "should a video key and params to build the upload URL" do
    @responses.each do |r|
      r.media(:type).should eql('video')
      r.media(:key).should_not be_empty
      r.link(:path).should eql('/v1/videos/upload')
      r.link.query(:token).should_not be_empty
      r.link.query(:key).should_not be_empty
      r.link.protocol.should eql('http')
      r.link.address.should_not be_empty
    end
  end
end
