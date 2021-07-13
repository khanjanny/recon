package scanning

import "regexp"

// Grepping is function for checking pattern
func Grepping(data, regex string) []string {
	byteData := []byte(data)
	var bodySlice []string
	var pattern = regexp.MustCompile(regex)
	result := pattern.FindAllIndex(byteData, -1)
	_ = result

	for _, v := range result {
		bodySlice = append(bodySlice, data[v[0]:v[1]])
	}
	return bodySlice
}

// builtinGrep is dalfox build-in grep pattern
func builtinGrep(data string) map[string][]string {
	// "pattern name":["list of grep"]
	result := make(map[string][]string)
	// "pattern name":"regex"
	pattern := map[string]string{
		"dalfox-ssti":                  "2958816",
		"dalfox-rsa-key":               "-----BEGIN RSA PRIVATE KEY-----|-----END RSA PRIVATE KEY-----",
		"dalfox-priv-key":              "-----BEGIN PRIVATE KEY-----|-----END PRIVATE KEY-----",
		"dalfox-aws-s3":                "s3\\.amazonaws.com[/]+|[a-zA-Z0-9_-]*\\.s3\\.amazonaws.com",
		"dalfox-slack-webhook":         "https://hooks.slack.com/services/T[a-zA-Z0-9_]{8}/B[a-zA-Z0-9_]{8}/[a-zA-Z0-9_]{24}",
		"dalfox-slack-token":           "(xox[p|b|o|a]-[0-9]{12}-[0-9]{12}-[0-9]{12}-[a-z0-9]{32})",
		"dalfox-facebook-oauth":        "[f|F][a|A][c|C][e|E][b|B][o|O][o|O][k|K].{0,30}['\"\\s][0-9a-f]{32}['\"\\s]",
		"dalfox-twitter-oauth":         "[t|T][w|W][i|I][t|T][t|T][e|E][r|R].{0,30}['\"\\s][0-9a-zA-Z]{35,44}['\"\\s]",
		"dalfox-heroku-api":            "[h|H][e|E][r|R][o|O][k|K][u|U].{0,30}[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}",
		"dalfox-mailgun-api":           "key-[0-9a-zA-Z]{32}",
		"dalfox-mailchamp-api":         "[0-9a-f]{32}-us[0-9]{1,2}",
		"dalfox-picatic-api":           "sk_live_[0-9a-z]{32}",
		"dalfox-google-oauth-id":       "[0-9(+-[0-9A-Za-z_]{32}.apps.qooqleusercontent.com",
		"dalfox-google-api":            "AIza[0-9A-Za-z-_]{35}",
		"dalfox-google-oauth":          "ya29\\.[0-9A-Za-z\\-_]+",
		"dalfox-aws-access-key":        "AKIA[0-9A-Z]{16}",
		"dalfox-amazon-mws-auth-token": "amzn\\.mws\\.[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
		"dalfox-facebook-access-token": "EAACEdEose0cBA[0-9A-Za-z]+",
		"dalfox-authorization-basic":   "basic [a-zA-Z0-9_\\-:\\.]+",
		"dalfox-authorization-beare":   "bearer [a-zA-Z0-9_\\-\\.]+",
		"dalfox-github-access-token":   "[a-zA-Z0-9_-]*:[a-zA-Z0-9_\\-]+@github\\.com*",
		"dalfox-azure-storage":         "[a-zA-Z0-9_-]*\\.file.core.windows.net",
		"dalfox-error-mysql":           "(SQL syntax.*MySQL|Warning.*mysql_.*|MySqlException \\(0x|valid MySQL result|check the manual that corresponds to your (MySQL|MariaDB) server version|MySqlClient\\.|com\\.mysql\\.jdbc\\.exceptions)",
		"dalfox-error-postgresql":      "(PostgreSQL.*ERROR|Warning.*\\Wpg_.*|valid PostgreSQL result|Npgsql\\.|PG::SyntaxError:|org\\.postgresql\\.util\\.PSQLException|ERROR:\\s\\ssyntax error at or near)",
		"dalfox-error-mssql":           "(Driver.* SQL[\\-\\_\\ ]*Server|OLE DB.* SQL Server|\bSQL Server.*Driver|Warning.*mssql_.*|\bSQL Server.*[0-9a-fA-F]{8}|[\\s\\S]Exception.*\\WSystem\\.Data\\.SqlClient\\.|[\\s\\S]Exception.*\\WRoadhouse\\.Cms\\.|Microsoft SQL Native Client.*[0-9a-fA-F]{8})",
		"dalfox-error-msaccess":        "(Microsoft Access (\\d+ )?Driver|JET Database Engine|Access Database Engine|ODBC Microsoft Access)",
		"dalfox-error-oracle":          "(\\bORA-\\d{5}|Oracle error|Oracle.*Driver|Warning.*\\Woci_.*|Warning.*\\Wora_.*)",
		"dalfox-error-ibmdb2":          "(CLI Driver.*DB2|DB2 SQL error|\\bdb2_\\w+\\(|SQLSTATE.+SQLCODE)",
		"dalfox-error-informix":        "(Exception.*Informix)",
		"dalfox-error-firebird":        "(Dynamic SQL Error|Warning.*ibase_.*)",
		"dalfox-error-sqlite":          "(SQLite\\/JDBCDriver|SQLite.Exception|System.Data.SQLite.SQLiteException|Warning.*sqlite_.*|Warning.*SQLite3::|\\[SQLITE_ERROR\\])",
		"dalfox-error-sapdb":           "(SQL error.*POS([0-9]+).*|Warning.*maxdb.*)",
		"dalfox-error-sybase":          "(Warning.*sybase.*|Sybase message|Sybase.*Server message.*|SybSQLException|com\\.sybase\\.jdbc)",
		"dalfox-error-ingress":         "(Warning.*ingres_|Ingres SQLSTATE|Ingres\\W.*Driver)",
		"dalfox-error-frontbase":       "(Exception (condition )?\\d+. Transaction rollback.)",
		"dalfox-error-hsqldb":          "(org\\.hsqldb\\.jdbc|Unexpected end of command in statement \\[|Unexpected token.*in statement \\[)",

		//sqli
		/////////////////////////////////////////////////////////

		//mysql
		"dalfox-error-mysql1":  "SQL syntax.*?MySQL",
		"dalfox-error-mysql2":  "Warning.*?mysqli?",
		"dalfox-error-mysql3":  "MySQLSyntaxErrorException",
		"dalfox-error-mysql4":  "valid MySQL result",
		"dalfox-error-mysql5":  "check the manual that (corresponds to|fits) your MySQL server version",
		"dalfox-error-mysql6":  "check the manual that (corresponds to|fits) your MariaDB server version",
		"dalfox-error-mysql7":  "check the manual that (corresponds to|fits) your Drizzle server version",
		"dalfox-error-mysql8":  "Unknown column '[^ ]+' in 'field list'",
		"dalfox-error-mysql9":  "com\\.mysql\\.jdbc",
		"dalfox-error-mysql10": "Zend_Db_(Adapter|Statement)_Mysqli_Exception",
		"dalfox-error-mysql11": "MySqlException",
		"dalfox-error-mysql12": "Syntax error or access violation",

		//psql
		"dalfox-error-psql1":  "PostgreSQL.*?ERROR",
		"dalfox-error-psql2":  "Warning.*?\\Wpg_",
		"dalfox-error-psql3":  "valid PostgreSQL result",
		"dalfox-error-psql4":  "Npgsql\\.",
		"dalfox-error-psql5":  "PG::SyntaxError:",
		"dalfox-error-psql6":  "org\\.postgresql\\.util\\.PSQLException",
		"dalfox-error-psql7":  "ERROR:\\s\\ssyntax error at or near",
		"dalfox-error-psql8":  "ERROR: parser: parse error at or near",
		"dalfox-error-psql9":  "PostgreSQL query failed",
		"dalfox-error-psql10": "org\\.postgresql\\.jdbc",
		"dalfox-error-psql11": "PSQLException",

		//mssql
		"dalfox-error-mssql1":  "Driver.*? SQL[\\-\\_\\ ]*Server",
		"dalfox-error-mssql2":  "OLE DB.*? SQL Server",
		"dalfox-error-mssql3":  "\bSQL Server[^&lt;&quot;]+Driver",
		"dalfox-error-mssql4":  "Warning.*?\\W(mssql|sqlsrv)_",
		"dalfox-error-mssql5":  "\bSQL Server[^&lt;&quot;]+[0-9a-fA-F]{8}",
		"dalfox-error-mssql6":  "System\\.Data\\.SqlClient\\.SqlException",
		"dalfox-error-mssql7":  "(?s)Exception.*?\bRoadhouse\\.Cms\\.",
		"dalfox-error-mssql8":  "Microsoft SQL Native Client error '[0-9a-fA-F]{8}",
		"dalfox-error-mssql9":  "\\[SQL Server\\]",
		"dalfox-error-mssql10": "ODBC SQL Server Driver",
		"dalfox-error-mssql11": "ODBC Driver \\d+ for SQL Server",
		"dalfox-error-mssql12": "SQLServer JDBC Driver",
		"dalfox-error-mssql13": "com\\.jnetdirect\\.jsql",
		"dalfox-error-mssql14": "macromedia\\.jdbc\\.sqlserver",
		"dalfox-error-mssql15": "Zend_Db_(Adapter|Statement)_Sqlsrv_Exception",
		"dalfox-error-mssql16": "com\\.microsoft\\.sqlserver\\.jdbc",
		"dalfox-error-mssql18": "SQL(Srv|Server)Exception",
	}
	for k, v := range pattern {
		resultArr := Grepping(data, v)
		if len(resultArr) > 0 {
			result[k] = resultArr
		}
	}

	return result
}

// customGrep is user custom grep pattern
func customGrep(data string, pattern map[string]string) map[string][]string {
	// "pattern name":""
	result := make(map[string][]string)
	for k, v := range pattern {
		resultArr := Grepping(data, v)
		if len(resultArr) > 0 {
			result[k] = resultArr
		}
	}
	return result
}
