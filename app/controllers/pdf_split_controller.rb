class PdfSplitController < ApplicationController

  def index
  end

  def split_pdf
    if !params[:pdf] || (params[:pdf] && !params[:pdf].content_type.split('/').include?('pdf'))
      session[:errors] = "Please upload a pdf file"
      redirect_to root_path
    end
    uploaded_file_name = params[:pdf].original_filename.split(".pdf")[0].gsub!(/[^0-9A-Za-z]/, '')
    uploaded_file_path = params[:pdf].tempfile.path
    FileUtils.mkdir_p(uploaded_file_name)
		reader = PDF::Reader.new(uploaded_file_path)
		i = 0
		CombinePDF.load(uploaded_file_path).pages.each do |joint_file|
			i+=1
			read_page = reader.page(i)
			file_name = read_page.text.scan(/^.+/)[0].strip.gsub!(/[^0-9A-Za-z ]/, '')
			file_name = "#{file_name.titlecase}.pdf"
			file_path = Rails.root.join(uploaded_file_name,file_name)
			pdf = CombinePDF.new
			pdf << joint_file
			pdf.save(file_path)
		end
		folder_path = Rails.root.join(uploaded_file_name)
		system("zip -r #{uploaded_file_name} '#{folder_path}'")
		send_file(File.join("#{uploaded_file_name}.zip"))
  end
end
