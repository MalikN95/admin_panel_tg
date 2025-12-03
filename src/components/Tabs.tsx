interface TabsProps {
  activeTab: 'chats' | 'bots';
  onTabChange: (tab: 'chats' | 'bots') => void;
}

export const Tabs = ({ activeTab, onTabChange }: TabsProps) => {
  return (
    <div className="flex border-b border-gray-700 bg-gray-800">
      <button
        onClick={() => onTabChange('chats')}
        className={`flex-1 px-4 py-3 text-sm font-medium transition-colors ${
          activeTab === 'chats'
            ? 'text-white border-b-2 border-blue-500'
            : 'text-gray-400 hover:text-white'
        }`}
      >
        Чаты
      </button>
      <button
        onClick={() => onTabChange('bots')}
        className={`flex-1 px-4 py-3 text-sm font-medium transition-colors ${
          activeTab === 'bots'
            ? 'text-white border-b-2 border-blue-500'
            : 'text-gray-400 hover:text-white'
        }`}
      >
        Боты
      </button>
    </div>
  );
};

