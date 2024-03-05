package apiFunctions;
/**
 * @author pbhallamudi
 * Exception
 */
public class CannotVerifyResultException extends Exception {
    
	private static final long serialVersionUID = 1L;

	public CannotVerifyResultException(String message) {
                   // the given message as its error message.
       super(message);
    }
 }