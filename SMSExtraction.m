function [ Tokens ] = SMSExtraction(MsgTxt)
           
    %% Text pre-processing
    MsgTxt=lower(MsgTxt);
    MsgTxt = regexprep(MsgTxt, '&lt;', '<');
    MsgTxt = regexprep(MsgTxt, '&gt;', '>');
    MsgTxt = regexprep(MsgTxt, '&amp;', '&');
    MsgTxt = regexprep(MsgTxt, '&quot;', '"');
    MsgTxt=  regexprep(MsgTxt, '[‘|’]', '''');
    MsgTxt=  regexprep(MsgTxt, '[…]', '...');
    MsgTxt=  regexprep(MsgTxt, '[–|—]', '-');
    MsgTxt=  regexprep(MsgTxt, '[»]', '>>');
    MsgTxt=  regexprep(MsgTxt, '[ü|Ü]', 'u');    
    MsgTxt=  regexprep(MsgTxt, '[0-9]', '9');
    
    MsgTxt = regexprep(MsgTxt,'(https:|http:|https|http)//[^\s]*', ' URL ');
    MsgTxt = regexprep(MsgTxt,'www.[^\s]*', 'URL');
    MsgTxt = regexprep(MsgTxt,'\s[^\s]*(\.com)[^\s]*', ' URL');
    MsgTxt = regexprep(MsgTxt,'[^\s]*(\.com)[^\s]*', ' URL ');
    MsgTxt = regexprep(MsgTxt, '[^\s]+@[^\s]+', ' EMAIL ');
    
    MsgTxt = regexprep(MsgTxt, '(\$|£)', '$');
    MsgTxt = regexprep(MsgTxt, '(pounds|pound|dollars|dollar|usd)', '$');
    MsgTxt = regexprep(MsgTxt, '[0-9]+[\s]*(\$)+', ' MONEY ');
    MsgTxt = regexprep(MsgTxt, '(\$)+[\s]*[0-9]+', ' MONEY ');             
    
    MsgTxt = regexprep(MsgTxt, '(t''s and c''s|t''s & c''s|t''s&c''s|t & c''s|t&c''s|tsandc|ts&cs|t&cs|t &cs|t&cs| t cs |t&c|tnc|tscs)', ' THANKS '); %
    
    MsgTxt = regexprep(MsgTxt, ':-)', ' FACE ');
    MsgTxt = regexprep(MsgTxt, ':-(', ' FACE ');
    MsgTxt = regexprep(MsgTxt, ':)', ' FACE ');
    MsgTxt = regexprep(MsgTxt, ':(', ' FACE ');
    MsgTxt = regexprep(MsgTxt, ';-)', ' FACE ');
    MsgTxt = regexprep(MsgTxt, ';-(', ' FACE ');
    MsgTxt = regexprep(MsgTxt, ';)', ' FACE ');
    MsgTxt = regexprep(MsgTxt, ';(', ' FACE ');
    MsgTxt = regexprep(MsgTxt, '(:', ' FACE ');
    MsgTxt = regexprep(MsgTxt, '):', ' FACE ');
    MsgTxt = regexprep(MsgTxt, '^-^', ' FACE ');
    MsgTxt = regexprep(MsgTxt, '^_^', ' FACE ');
    MsgTxt = regexprep(MsgTxt, ':>', ' FACE ');
    MsgTxt = regexprep(MsgTxt, '<:', ' FACE ');
    MsgTxt = regexprep(MsgTxt, ';>', ' FACE ');
    MsgTxt = regexprep(MsgTxt, '<;', ' FACE ');
        
    MsgTxt = regexprep(MsgTxt, '[@|/|#|.|-|:|&|*|+|=|[|]|?|!|(|)|{|}|,|''|>|_|<|;|%|"|-|$]', ' ');
    
    %% Extract all alpha-numeric keywords
    keywords=regexp(MsgTxt,'[^ ]+','match');
    [p,keyword_count]=size(keywords);
    all_keyword_list=cell(0);
    for i=1:keyword_count
        keyword=keywords{1,i};
        keyword_list=regexp(keyword,'[A-Za-z0-9]+','match');
        keyword_list=transpose(keyword_list);
        if(i==1)
            all_keyword_list=keyword_list;
        else
            all_keyword_list=[all_keyword_list;keyword_list];
        end
    end
    
    %% Count keywords
    count=1;
    Tokens=cell(0);
    [len,p]=size(all_keyword_list);
    num_count=0;
    alphanumeric_count=0;
    phone_count=0;
    
    for i=1:len
        keyword=all_keyword_list{i,1};

        hh=regexp(keyword,'[0-9]+','match');
        if(length(hh)==1 && strcmp(hh,keyword)==1)
               % This number is phone number or SMS number
                if(length(keyword)>7||length(keyword)==5)
                        phone_count=phone_count+1;
                else
                    % This number is a long phone number consists of two
                    % parts
                        if(length(keyword)==7 && length(all_keyword_list{i-1,1})==4)
                              phone_count=phone_count+1;
                              num_count=num_count-1;
                              continue;
                        end
                        num_count=num_count+1;
                end
                continue;
        end
        
        gg=regexp(keyword,'[a-z]+','match');
        if(~isempty(hh) && ~isempty(gg))
                alphanumeric_count=alphanumeric_count+1;
                continue;
        end
        
%         if(Is_stopwords(keyword)==1)
%              continue;
%         end

        finalword=porterStemmer(keyword);
        if(~isempty(Tokens))
                TokenText=Tokens(:,1);
                index = find(strcmp(finalword, TokenText));
                if(~isempty(index))
                    t=cell2mat(Tokens(index,2));
                    Tokens(index,2)={t+1};
                else
                    Tokens(count,1)={finalword};
                    Tokens(count,2)={1};
                    count=count+1;
                end
        else
                Tokens(count,1)={finalword};
                Tokens(count,2)={1};
                 count=count+1;
        end
    end

     if(alphanumeric_count>0)
        Tokens(count,1)={'ALPHANUMERIC'};
        Tokens(count,2)={alphanumeric_count};
        count=count+1;
     end
       
    if(num_count>0)
        Tokens(count,1)={'NUMBER'}; % without money number
        Tokens(count,2)={num_count};      
        count=count+1;
    end
    
    if(phone_count>0)
        Tokens(count,1)={'PHONE'};
        Tokens(count,2)={phone_count};
%         count=count+1;
    end
end

%% stopwords
function stopword = Is_stopwords( inString )
% Source of stopwords- http://norm.al/2009/04/14/list-of-english-stop-words/

stopwords_cellstring={'a', 'about', 'above', 'above', 'across', 'after', ...
    'afterwards', 'again', 'against', 'all', 'almost', 'alone', 'along', ...
    'already', 'also','although','always','am','among', 'amongst', 'amoungst', ...
    'amount',  'an', 'and', 'another', 'any','anyhow','anyone','anything','anyway', ...
    'anywhere', 'are', 'around', 'as',  'at', 'back','be','became', 'because','become',...
    'becomes', 'becoming', 'been', 'before', 'beforehand', 'behind', 'being', 'below',...
    'beside', 'besides', 'between', 'beyond', 'bill', 'both', 'bottom','but', 'by',...
    'call', 'can', 'cannot', 'cant', 'co', 'con', 'could', 'couldnt', 'cry', 'de',...
    'describe', 'detail', 'do', 'done', 'down', 'due', 'during', 'each', 'eg', 'eight',...
    'either', 'eleven','else', 'elsewhere', 'empty', 'enough', 'etc', 'even', 'ever', ...
    'every', 'everyone', 'everything', 'everywhere', 'except', 'few', 'fifteen', 'fify',...
    'fill', 'find', 'fire', 'first', 'five', 'for', 'former', 'formerly', 'forty', 'found',...
    'four', 'from', 'front', 'full', 'further', 'get', 'give', 'go', 'had', 'has', 'hasnt',...
    'have', 'he', 'hence', 'her', 'here', 'hereafter', 'hereby', 'herein', 'hereupon', ...
    'hers', 'herself', 'him', 'himself', 'his', 'how', 'however', 'hundred', 'ie', 'if',...
    'in', 'inc', 'indeed', 'interest', 'into', 'is', 'it', 'its', 'itself', 'keep', 'last',...
    'latter', 'latterly', 'least', 'less', 'ltd', 'made', 'many', 'may', 'me', 'meanwhile',...
    'might', 'mill', 'mine', 'more', 'moreover', 'most', 'mostly', 'move', 'much', 'must',...
    'my', 'myself', 'name', 'namely', 'neither', 'never', 'nevertheless', 'next', 'nine',...
    'no', 'nobody', 'none', 'noone', 'nor', 'not', 'nothing', 'now', 'nowhere', 'of', 'off',...
    'often', 'on', 'once', 'one', 'only', 'onto', 'or', 'other', 'others', 'otherwise',...
    'our', 'ours', 'ourselves', 'out', 'over', 'own','part', 'per', 'perhaps', 'please',...
    'put', 'rather', 're', 'same', 'see', 'seem', 'seemed', 'seeming', 'seems', 'serious',...
    'several', 'she', 'should', 'show', 'side', 'since', 'sincere', 'six', 'sixty', 'so',...
    'some', 'somehow', 'someone', 'something', 'sometime', 'sometimes', 'somewhere', ...
    'still', 'such', 'system', 'take', 'ten', 'than', 'that', 'the', 'their', 'them',...
    'themselves', 'then', 'thence', 'there', 'thereafter', 'thereby', 'therefore', ...
    'therein', 'thereupon', 'these', 'they', 'thickv', 'thin', 'third', 'this', 'those',...
    'though', 'three', 'through', 'throughout', 'thru', 'thus', 'to', 'together', 'too',...
    'top', 'toward', 'towards', 'twelve', 'twenty', 'two', 'un', 'under', 'until', 'up',...
    'upon', 'us', 'very', 'via', 'was', 'we', 'well', 'were', 'what', 'whatever', 'when',...
    'whence', 'whenever', 'where', 'whereafter', 'whereas', 'whereby', 'wherein',...
    'whereupon', 'wherever', 'whether', 'which', 'while', 'whither', 'who', 'whoever',...
    'whole', 'whom', 'whose', 'why', 'will', 'with', 'within', 'without', 'would', 'yet',...
    'you', 'your', 'yours', 'yourself', 'yourselves','u','i','ur','r','ve',...
    'm','k','g','d','b','e','v','f','o','c','t','s'};
    stopword = ismember(inString,stopwords_cellstring);
end