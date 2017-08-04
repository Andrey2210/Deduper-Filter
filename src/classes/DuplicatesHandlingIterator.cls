global with sharing class DuplicatesHandlingIterator implements Iterable<SObject> {

	public List<SObject> recordsToHandle { get; private set; }

	public DuplicatesHandlingIterator(List<SObject> recordsToHandle) {
		this.recordsToHandle = recordsToHandle;
	}

	global Iterator<SObject> iterator() {
		return new DuplicatesHandlingInnerIterator(recordsToHandle);
	}

	global class DuplicatesHandlingInnerIterator implements Iterator<SObject> {

		public List<SObject> recordsToHandle { get; private set; }
		public Integer iteration { get; private set; }

		public DuplicatesHandlingInnerIterator(List<SObject> recordsToHandle) {
			this.recordsToHandle = recordsToHandle;
			iteration = 0;
		}

		global Boolean hasNext() {
			return iteration < recordsToHandle.size();
		}

		global SObject next() {
			iteration += 1;
			return recordsToHandle[iteration - 1];
		}

	}

}