require 'json'

shared_context 'with VisualCrossing response' do
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'files', 'visual_crossing', 'timeline_98122.json') }
  let(:vc_json_data) do
    JSON.parse(File.read(file_path))
  end
end
