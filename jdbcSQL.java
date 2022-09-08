import java.sql.*;
import java.lang.*;

public class Assignment2 {


	public Connection connection;


	public Assignment2() {
		try {
			Class.forName("org.postgresql.Driver");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}


	public boolean connectDB(String URL, String username, String password) {
		try {
			connection = DriverManager.getConnection(URL, username, password);
			return conncetion == null ? false : true;
		} catch (Exception e) {
			e.printStackTrace();
		}
	}


	public boolean disconnectDB() {
		try {
			connection.close();
			return true;
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}


	public boolean insertPlayer(int id, String playerName, String email, String countryCode) {
		//check the validity of countryCode
		if (countryCode.length() != 3) return false;
		for (int i=0; i<3; i++)	if (Character.isLowerCase(countryCode[i])) return false;
		//check if any of id, playerName or email exists
				
	    try {
	    	Statement statement = connection.createStatement();
	        String sql = "SELECT id, playername, email FROM Player";
	        ResultSet rs = statement.executeQuery(sql);
	        while (rs.next()) {
	        	int p_id = rs.getInt(1);
	        	String p_name = rs.getString(2);
	        	String p_email = rs.getString(3);
	        	if (p_id == id || playerName.equals(p_name) || email.equals(p_email)) {
	        		rs.close();
	        		statement.close();
	        		return false;
	        	}
	        }
	        rs.close();
	        statement.close();
	        
	        //do the insertion query
	        PreparedStatement ps=connection.prepareStatement(
	        		"INSERT INTO Player (id, playername, email, country_code) VALUES (?, ?, ?, ?)");
	        ps.setObject(1, id);
	        ps.setObject(2, playerName);
	        ps.setObject(3, email);
	        ps.setObject(4, countryCode);
	        int result = ps.executeUpdate();
	        ps.close();
	        return true;
	    } catch (Exception e) {
	    	e.printStackTrace();
	    	return false;
	    }
	}


	public int getMembersCount(int gid) {
		try {
			Statement statement = connection.createState();
			String sql = "SELECT count(id), guild FROM Player WHERE guild="+Integer.toString(gid) +" GROUP BY guild";
			ResultSet rs = statement.executeQuery(sql);
			if (rs.next()) {
				int members = rs.getInt(1);
				rs.close();
				statement.close();
				return members;
			}
			rs.close();
			statement.close();
			return -1;
		} catch (Exception e) {
			e.printStackTrace();
			return -1;
		}
	}


	public String getPlayerInfo(int id) {
		try {
			Statement statement = connection.createState();
			String sql = "SELECT * FROM Player WHERE id="+Integer.toString(id);
			ResultSet rs = statement.executeQuery(sql);
			if (rs.next()) {
				String playerName = rs.getString(2);
				String email = rs.getString(3);
				String countryCode = rs.getString(4);
				int coins = rs.getInt(5);
				int rolls = rs.getInt(6);
				int wins = rs.getInt(7);
				int losses = rs.getInt(8);
				int total_battles = rs.getInt(9);
				String guild = "";
				if (rs.getObject(10)!=null) {
				    guild = Integer.toString(rs.getInt(10));
				}
				rs.to
				rs.close();
				statement.close();
				return Integer.toString(id) +":"+playerName +":" + email +":" + countryCode +":" 
				       + Integer.toString(coins) +":" + Integer.toString(rolls) + ":" + Integer.toString(wins)
				       + ":" + Integer.toString(losses) + ":" + Integer.toString(total_battles) + ":" 
				       + guild;
			}
			rs.close();
			statement.close();
			return "";
		} catch (Exception e) {
			e.printStackTrace();
		}
	}


	public boolean changeGuild(String oldName, String newName) {
		try {
		    PreparedStatement ps = connection.prepareStatement(
	        		"SELECT id FROM Guild WHERE guildname=?");
		    //check if newName exists
			ps.setObject(1, newName);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				rs.close();
				ps.close();
				return false;
			}
			rs.close();
			ps.close();
		    
			//check if oldName exists
			ps = connection.prepareStatement(
	        		"SELECT id FROM Guild WHERE guildname=?");
			ps.setObject(1, oldName);
			rs = ps.executeQuery();
			if (!rs.next()) {
				rs.close();
				ps.close();
				return false;
			}
			int gid = rs.getInt(1);
			ps.close();
			rs.close();
			
			//Update Guild
			PreparedStatement prs = connection.prepareStatement("UPDATE Guild SET guildname=? WHERE id=?");
			prs.setObject(1, newName);
			prs.setObject(2, gid);
			int result = prs.executeUpdate();
			prs.close();
			return true;
			
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
		
	}


	public boolean deleteGuild(String guildName) {
		try {
		    PreparedStatement ps=connection.prepareStatement(
	        		"SELECT id FROM Guild WHERE guildname=?");
		   //check if guild exists
			ps.setObject(1, guildName);
			rs = ps.executeQuery();
			if (!rs.next()) {
				rs.close();
				ps.close();
				return false;
			}
			int gid = rs.getInt(1);
			ps.close();
			rs.close();
			//Delete from Guild
			PreparedStatement prs = connection.prepareStatement("DELETE FROM Guild WHERE id=?");
			prs.setObject(1, gid);
			int result = prs.executeUpdate();
			prs.close();
			return true;
			
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}


	public String listAllTimePlayerRatings() {
		try {
			Statement statement = connection.createStatement();
			String sql = "SELECE playername, all_time_rating "
					   + "FROM Player, (SELECT p_id, all_time_rating, row_number() OVER(PARTITION BY p_id ORDER BY year DESC, month DECS) rn"
					                 + "FROM PlayerRatings"
					                 + "WHERE rn = 1) p "
					   + "WHERE Player.id = p.p_id"
					   + "ORDER BY all_time_rating DESC";
			ResultSet rs = statement.executeQuery(sql);
			String output = "";
			while (rs.next()) {
				String pname = rs.getString(1);
				String rating = Integer.toString(rs.getInt(2));
				output = output + pname + ":" + rating + ":";
			}
			rs.close();
			statement.close();
			return output;
			
		} catch (Exception e) {
			e.printStackTrace();
			return "";
		}
	}


	public boolean updateMonthlyRatings() {
		try {
			Statement statement = connection.createStatement();
			String oldPlayerView = "INSERT INTO PlayerRatings (p_id, month, year, monthly_rating, all_time_rating)"
					             + "(SELECT p_id, 10 AS month, year, 1.1 * monthly_rating AS monthly_rating, 1.1 * all_time_rating AS all_time_rating"
					             + "FROM PlayerRatings"
					             + "WHERE month = 9 AND year = 2021)";
			statement.executeUpdate(oldPlayerView);
			
			String oldGuildView = "INSERT INTO GuildRatings (g_id, month, year, monthly_rating, all_time_rating)"
					            + "(SELECT g_id, 10 AS month, year, 1.1 * monthly_rating AS monthly_rating, 1.1 * all_time_rating AS all_time_rating"
		                        + "FROM GuildRatings"
		                        + "WHERE month = 9 AND year = 2021)";
			statement.executeUpdate(oldGuildView);
            
            String newPlayer = "SELECT id FROM Player WHERE id NOT IN (SELECT p_id AS id FROM PlayerRatings)";
            ResultSet rs3 = statement.executeQuery(newPlayer);
            
            String newGuild = "SELECT id FROM Guild WHERE id NOT IN (SELECT g_id AS id FROM GuildRatings)";
            ResultSet rs4 = statement.executeQuery(newGuild);
            statement.close();
                        
            while(rs3.next()) {
            	PreparedStatement ps1 = connection.prepareStatement("INSERT INTO PlayerRatings (p_id, month, year, monthly_rating, all_time_rating)"
            			                                          + " VALUES(?, 10, 2021, 1000, 1000)");
            	ps1.setObject(1, rs3.getInt(1));
            	int result = ps1.executeUpdate();
            	ps1.close();
            }
            rs3.close();
    
            while(rs4.next()) {
            	PreparedStatement ps2 = connection.prepareStatement("INSERT INTO PlayerRatings (p_id, month, year, monthly_rating, all_time_rating)"
                                                                 + " VALUES(?, 10, 2021, 1000, 1000)"); 
            	ps2.setObject(1, rs4.getInt(1));
            	int result = ps2.executeUpdate();
            	ps2.close();
            }
            rs4.close();
            return true;
            
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}


	public boolean createSquidTable() {
		try {
			Statement statement = connection.createStatement();
			String newTable = "CREATE TABLE squidNation ("
					        + "id INTEGER PRIMARY KEY, "
					        + "playername VARCHAR UNIQUE NOT NULL,"
					        + "email VARCHAR UNIQUE NOT NULL,"
					        + "coins INTEGER NOT NULL DEFAULT 0,"
					        + "rolls INTEGER NOT NULL DEFAULT 0,"
					        + "wins INTEGER NOT NULL DEFAULT 0,"
					        + "losses INTEGER NOT NULL DEFAULT 0,"
					        + "total_battles INTEGER NOT NULL DEFAULT 0,"
					        + ")";
			int result = statement.executeUpdate(newTable);
			
			String insertion = "INSERT INTO squidNatioin (SELECT Player.id AS id, playername, email, coins, rolls, wins, losses, total_battles"
					                                   + "FROM Player JOIN Guild ON Player.guild = Guild.id"
					                                   + "WHERE guildname = 'Squid Game' AND country_code = 'KOR'"
					                                   + "ORDER BY Player.id)";
			int result = statement.executeUpdate(insertion);
			statement.close();
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}

	}
	
	
	public boolean deleteSquidTable() {
		try {
			Statement statement = connection.createStatement();
			String sql = "DROP TABLE IF EXISTS squidNatioin CASCADE";
			int result = statement.executeUpdate(sql);
			statement.close();
			return true
			
		}  catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
}
