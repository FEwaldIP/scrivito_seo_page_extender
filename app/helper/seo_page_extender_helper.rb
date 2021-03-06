module SeoPageExtenderHelper
  def words_density(obj, attribute)
    words = get_words_from_page(obj, attribute).map { |e| e.downcase.gsub(/[^a-z0-9\s]/i, '') }
    without_stop_words = remove_stop_words(words)
    return {
      count: without_stop_words.count,
      density_for_one: density_with_one_word(without_stop_words),
      density_for_two: density_with_n_word(2,without_stop_words),
      density_for_three: density_with_n_word(3,without_stop_words)
    }
  end

  def canonical_link(obj)
    if obj.respond_to?(:meta_canonical) && obj.meta_canonical.present?
      obj.meta_canonical
    else
      "https://#{request.raw_host_with_port + scrivito_path(obj)}"
    end
  end

  private
  def get_words_from_page(obj, attribute)
    strip_tags(scrivito_tag(:span, obj, attribute).to_s).split(" ")
  end

  def calulate_count_of_all_words(words)
    words.each_with_object(Hash.new(0)) {|word,counts| counts[word] += 1 }
  end

  def remove_stop_words(density)
    density.select {|e| !stop_words_fallback.include? e}
  end

  def density_with_one_word(words)
    calulate_count_of_all_words(words).sort_by {|word,count| count}.reverse
  end

  def density_with_n_word(n, words)
    two_words = []
    words[0..-(n+1)].each_with_index do |word, index|
      two_words << words[index..index+n-1].join(" ")
    end
    return calulate_count_of_all_words(two_words).sort_by {|word,count| count}.reverse
  end

  def stop_words_fallback
    "a,able,about,across,after,all,almost,also,am,among,an,and,any,are,as,at,be,because,been,but,by,can,cannot,could,dear,did,do,does,either,else,ever,every,for,from,get,got,had,has,have,he,her,hers,him,his,how,however,i,if,in,into,is,it,its,just,least,let,like,likely,may,me,might,most,must,my,neither,no,nor,not,of,off,often,on,only,or,other,our,own,rather,said,say,says,she,should,since,so,some,than,that,the,their,them,then,there,these,they,this,tis,to,too,twas,us,wants,was,we,were,what,when,where,which,while,who,whom,why,will,with,would,yet,you,your".split(",")
  end
end