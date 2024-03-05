<html xmlns:viv="http://vivisimo.com/exslt">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<style type="text/css">
         b  {
               color:black;
               font-family:arial;
               font-size:90%;
               font-style:bold;
            }
         i  {
               color:black;
               font-family:arial;
               font-size:70%;
               font-style:italic;
            }
         i b  {
               color:black;
               font-size:150%;
               font-style:bold;
            }
         PASS  {
               color:green;
               font-size:90%;
               font-style:bold;
            }
         FAIL  {
               color:red;
               font-size:90%;
               font-style:bold;
            }
      </style>
<title>
               tryit
            </title>
</head>
<body><p><b>
                   version: 5.0-0</b><table border="1" align="center">
<caption><i><b>
         Test results for viv:str-to-mixed()
         </b></i></caption>
<tr>
<th><b>
            Test Value
            </b></th>
<th><b>
            Expected Value
            </b></th>
<th><b>
            Result
            </b></th>
<th><b>
            PASS/FAIL
            </b></th>
</tr>
<tbody>
<tr>
<td align="center"><i>
      abcdefghijklmnopqrstuvwxyz
      </i></td>
<td align="center"><i>
      Abcdefghijklmnopqrstuvwxyz
      </i></td>
<td align="center"><i>
      Abcdefghijklmnopqrstuvwxyz
      </i></td>
<td align="center"><i><PASS>
                        TEST PASSED
                        </PASS></i></td>
</tr>
<tr>
<td align="center"><i>
      ABCDEFGHIJKLMNOPQRSTUVWXYZ
      </i></td>
<td align="center"><i>
      Abcdefghijklmnopqrstuvwxyz
      </i></td>
<td align="center"><i>
      Abcdefghijklmnopqrstuvwxyz
      </i></td>
<td align="center"><i><PASS>
                        TEST PASSED
                        </PASS></i></td>
</tr>
<tr>
<td align="center"><i>
      !@# $%^&amp;*()_+=-[]{};':",.&lt;&gt;/?\|
      </i></td>
<td align="center"><i>
      !@# $%^&amp;*()_+=-[]{};':",.&lt;&gt;/?\|
      </i></td>
<td align="center"><i>
      !@# $%^&amp;*()_+=-[]{};':",.&lt;&gt;/?\|
      </i></td>
<td align="center"><i><PASS>
                        TEST PASSED
                        </PASS></i></td>
</tr>
<tr>
<td align="center"><i>
      1234567890
      </i></td>
<td align="center"><i>
      1234567890
      </i></td>
<td align="center"><i>
      1234567890
      </i></td>
<td align="center"><i><PASS>
                        TEST PASSED
                        </PASS></i></td>
</tr>
<tr>
<td align="center"><i>
      abcd1234
      </i></td>
<td align="center"><i>
      Abcd1234
      </i></td>
<td align="center"><i>
      Abcd1234
      </i></td>
<td align="center"><i><PASS>
                        TEST PASSED
                        </PASS></i></td>
</tr>
<tr>
<td align="center"><i>
      AbCd 1234
      </i></td>
<td align="center"><i>
      Abcd 1234
      </i></td>
<td align="center"><i>
      Abcd 1234
      </i></td>
<td align="center"><i><PASS>
                        TEST PASSED
                        </PASS></i></td>
</tr>
<tr>
<td align="center"><i>
      aAaA;bBbB
      </i></td>
<td align="center"><i>
      Aaaa;bbbb
      </i></td>
<td align="center"><i>
      Aaaa;bbbb
      </i></td>
<td align="center"><i><PASS>
                        TEST PASSED
                        </PASS></i></td>
</tr>
<tr>
<td align="center"><i>
      ;haliBUT-
      </i></td>
<td align="center"><i>
      ;halibut-
      </i></td>
<td align="center"><i>
      ;halibut-
      </i></td>
<td align="center"><i><PASS>
                        TEST PASSED
                        </PASS></i></td>
</tr>
<tr>
<td align="center"><i>
      November 21, 1994
      </i></td>
<td align="center"><i>
      November 21, 1994
      </i></td>
<td align="center"><i>
      November 21, 1994
      </i></td>
<td align="center"><i><PASS>
                        TEST PASSED
                        </PASS></i></td>
</tr>
<tr>
<td align="center"><i>
      11/21/1994
      </i></td>
<td align="center"><i>
      11/21/1994
      </i></td>
<td align="center"><i>
      11/21/1994
      </i></td>
<td align="center"><i><PASS>
                        TEST PASSED
                        </PASS></i></td>
</tr>
<tr>
<td align="center"><i>
      21-Nov-1994
      </i></td>
<td align="center"><i>
      21-Nov-1994
      </i></td>
<td align="center"><i>
      21-Nov-1994
      </i></td>
<td align="center"><i><PASS>
                        TEST PASSED
                        </PASS></i></td>
</tr>
<tr>
<td align="center"><i>
      the quick brown fox jumps over the lazy dog
      </i></td>
<td align="center"><i>
      The Quick Brown Fox Jumps Over The Lazy Dog
      </i></td>
<td align="center"><i>
      The Quick Brown Fox Jumps Over The Lazy Dog
      </i></td>
<td align="center"><i><PASS>
                        TEST PASSED
                        </PASS></i></td>
</tr>
<tr>
<td align="center"><i>
      the quick brown fox jumps over the lazy dog
      </i></td>
<td align="center"><i>
      The quick brown fox jumps over the lazy dog
      </i></td>
<td align="center"><i>
      The Quick Brown Fox Jumps Over The Lazy Dog
      </i></td>
<td align="center"><i><FAIL>
                        TEST FAILED
                        </FAIL></i></td>
</tr>
<tr>
<td align="center"><i>
      '    '
      </i></td>
<td align="center"><i>
      '    '
      </i></td>
<td align="center"><i>
      '    '
      </i></td>
<td align="center"><i><PASS>
                        TEST PASSED
                        </PASS></i></td>
</tr>
</tbody>
</table></p></body>
</html>
