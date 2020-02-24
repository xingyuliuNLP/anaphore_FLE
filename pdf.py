import PyPDF2
pdf_file = open('/Users/becca/Documents/these/GAO_memoireM2_010711.pdf', 'rb')
read_pdf = PyPDF2.PdfFileReader(pdf_file)

number_of_pages = read_pdf.getNumPages()
page = read_pdf.getPage(1)
page_content = page.extractText()
with open('pdf.txt', 'wb') as output:
  output.write(page_content.encode('utf-8'))

# import PyPDF2

# #write a for-loop to open many files -- leave a comment if you'd #like to learn how
# filename = '/Users/becca/Documents/these/GAO_memoireM2_010711.pdf' 

# #open allows you to read the file
# pdfFileObj = open(filename,'rb')
# #The pdfReader variable is a readable object that will be parsed
# pdfReader = PyPDF2.PdfFileReader(pdfFileObj)
# #discerning the number of pages will allow us to parse through all #the pages
# num_pages = pdfReader.numPages
# count = 0
# text = ""
# #The while loop will read each page
# while count < num_pages:
#     pageObj = pdfReader.getPage(count)
#     count +=1
#     text += pageObj.extractText()
# #This if statement exists to check if the above library returned #words. It's done because PyPDF2 cannot read scanned files.
# # if text != "":
#   #  text = text
# #If the above returns as False, we run the OCR library textract to #convert scanned/image based PDF files into text
# # else:
#   #  text = textract.process(fileurl, method='tesseract', language='eng')
# # Now we have a text variable which contains all the text derived #from our PDF file. Type print(text) to see what it contains. It #likely contains a lot of spaces, possibly junk such as '\n' etc.
# # Now, we will clean our text variable, and return it as a list of keywords.
# with open('pdf.txt', 'wb') as output:
  # output.write(text.encode('utf-8'))



